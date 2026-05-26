# frozen_string_literal: true

require_relative "test_helper"
require "socket"
require "json"

# Minimal HTTP stub server. Each test installs a response queue;
# the server pops one entry per request and writes it back.
class StubServer
  Response = Struct.new(:status, :headers, :body)

  attr_reader :port, :requests

  def initialize
    @server = TCPServer.new("127.0.0.1", 0)
    @port = @server.addr[1]
    @queue = []
    @requests = []
    @mutex = Mutex.new
    @thread = Thread.new { run }
  end

  def enqueue(status, body, headers = {})
    @mutex.synchronize { @queue << Response.new(status, headers, body) }
  end

  def base_url
    "http://127.0.0.1:#{@port}"
  end

  def stop
    @server.close
  rescue StandardError
    # ignore
  end

  private

  def run
    loop do
      client = @server.accept
      handle(client)
      client.close
    end
  rescue IOError, Errno::EBADF
    # server closed
  end

  def handle(client)
    request_line = client.gets
    return unless request_line

    headers = {}
    while (line = client.gets)
      break if line == "\r\n" || line == "\n" || line.nil?
      key, value = line.split(":", 2)
      headers[key.strip.downcase] = value.strip if key && value
    end

    body = ""
    if (len = headers["content-length"])
      body = client.read(len.to_i).to_s
    end

    @mutex.synchronize { @requests << { line: request_line.strip, headers: headers, body: body } }

    resp = @mutex.synchronize { @queue.shift }
    resp ||= Response.new(500, {}, '{"errors":[{"message":"no stub queued"}]}')

    status_text = {
      200 => "OK", 401 => "Unauthorized", 404 => "Not Found",
      409 => "Conflict", 422 => "Unprocessable Entity",
      429 => "Too Many Requests", 500 => "Internal Server Error",
      503 => "Service Unavailable"
    }[resp.status] || "Status"

    client.write("HTTP/1.1 #{resp.status} #{status_text}\r\n")
    client.write("Content-Type: application/json\r\n")
    client.write("Content-Length: #{resp.body.bytesize}\r\n")
    resp.headers.each { |k, v| client.write("#{k}: #{v}\r\n") }
    client.write("Connection: close\r\n\r\n")
    client.write(resp.body)
  rescue StandardError
    # ignore per-connection errors
  end
end

class TransportTest < Minitest::Test
  def setup
    @stub = StubServer.new
  end

  def teardown
    @stub.stop
  end

  def transport(**opts)
    Hivehook::GraphQLTransport.new(@stub.base_url, "test-key", max_retries: 0, **opts)
  end

  def test_success
    @stub.enqueue(200, JSON.generate({ data: { hello: "world" } }))
    result = transport.execute("query { hello }")
    assert_equal({ "hello" => "world" }, result)
  end

  def test_404_raises_not_found_with_status_and_extensions
    body = JSON.generate({
      errors: [{ message: "missing", extensions: { code: "NOT_FOUND", id: "abc" } }]
    })
    @stub.enqueue(200, body)
    err = assert_raises(Hivehook::NotFoundError) { transport.execute("q") }
    assert_kind_of Hivehook::APIError, err
    assert_equal "missing", err.message
    assert_equal 200, err.status_code
    assert_equal "NOT_FOUND", err.graphql_code
    assert_equal({ "code" => "NOT_FOUND", "id" => "abc" }, err.extensions)
  end

  def test_conflict
    body = JSON.generate({ errors: [{ message: "dup", extensions: { code: "CONFLICT" } }] })
    @stub.enqueue(200, body)
    err = assert_raises(Hivehook::ConflictError) { transport.execute("q") }
    assert_kind_of Hivehook::APIError, err
    assert_equal "CONFLICT", err.graphql_code
  end

  def test_validation
    body = JSON.generate({ errors: [{ message: "bad", extensions: { code: "VALIDATION" } }] })
    @stub.enqueue(200, body)
    err = assert_raises(Hivehook::ValidationError) { transport.execute("q") }
    assert_kind_of Hivehook::APIError, err
    assert_equal "VALIDATION", err.graphql_code
  end

  def test_401_raises_auth_error
    @stub.enqueue(401, JSON.generate({ errors: [{ message: "nope" }] }))
    err = assert_raises(Hivehook::AuthError) { transport.execute("q") }
    assert_kind_of Hivehook::APIError, err
    assert_equal 401, err.status_code
    assert_equal "nope", err.message
  end

  def test_429_with_retry_after_then_success
    @stub.enqueue(429, JSON.generate({ errors: [{ message: "slow down" }] }), { "Retry-After" => "0" })
    @stub.enqueue(200, JSON.generate({ data: { ok: true } }))
    t = Hivehook::GraphQLTransport.new(@stub.base_url, "k", max_retries: 1)
    result = t.execute("q")
    assert_equal({ "ok" => true }, result)
  end

  def test_429_exhausted_raises_rate_limit_with_retry_after
    @stub.enqueue(429, JSON.generate({ errors: [{ message: "slow" }] }), { "Retry-After" => "2" })
    t = Hivehook::GraphQLTransport.new(@stub.base_url, "k", max_retries: 0)
    err = assert_raises(Hivehook::RateLimitError) { t.execute("q") }
    assert_kind_of Hivehook::APIError, err
    assert_equal 429, err.status_code
    assert_in_delta 2.0, err.retry_after, 0.001
  end

  def test_5xx_retry_then_success
    @stub.enqueue(503, JSON.generate({ errors: [{ message: "down" }] }))
    @stub.enqueue(200, JSON.generate({ data: { ok: 1 } }))
    t = Hivehook::GraphQLTransport.new(@stub.base_url, "k", max_retries: 1)
    result = t.execute("q")
    assert_equal({ "ok" => 1 }, result)
  end

  def test_5xx_exhausted_raises_server_error
    @stub.enqueue(500, JSON.generate({ errors: [{ message: "boom" }] }))
    t = Hivehook::GraphQLTransport.new(@stub.base_url, "k", max_retries: 0)
    err = assert_raises(Hivehook::ServerError) { t.execute("q") }
    assert_kind_of Hivehook::APIError, err
    assert_equal 500, err.status_code
  end

  def test_malformed_json
    @stub.enqueue(200, "{not json")
    err = assert_raises(Hivehook::APIError) { transport.execute("q") }
    assert_match(/malformed JSON/, err.message)
  end

  def test_auth_skipped_from_retry
    # 401 returns immediately; no retry loop even with max_retries set.
    @stub.enqueue(401, JSON.generate({ errors: [{ message: "no" }] }))
    t = Hivehook::GraphQLTransport.new(@stub.base_url, "k", max_retries: 3)
    assert_raises(Hivehook::AuthError) { t.execute("q") }
    assert_equal 1, @stub.requests.size
  end

  def test_notfound_not_retried
    body = JSON.generate({ errors: [{ message: "nope", extensions: { code: "NOT_FOUND" } }] })
    @stub.enqueue(200, body)
    t = Hivehook::GraphQLTransport.new(@stub.base_url, "k", max_retries: 3)
    assert_raises(Hivehook::NotFoundError) { t.execute("q") }
    assert_equal 1, @stub.requests.size
  end
end
