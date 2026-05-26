# frozen_string_literal: true

require "net/http"
require "uri"
require "json"
require_relative "version"

module Hivehook
  class GraphQLTransport
    DEFAULT_OPEN_TIMEOUT = 10
    DEFAULT_READ_TIMEOUT = 30
    DEFAULT_MAX_RETRIES = 2

    def initialize(base_url, api_key = nil, open_timeout: DEFAULT_OPEN_TIMEOUT,
                   read_timeout: DEFAULT_READ_TIMEOUT, max_retries: DEFAULT_MAX_RETRIES)
      @base_url = base_url
      @api_key = api_key
      @open_timeout = open_timeout
      @read_timeout = read_timeout
      @max_retries = max_retries
    end

    def execute(query, variables = {})
      uri = URI("#{@base_url}/graphql")

      attempt = 0
      loop do
        response = do_request(uri, query, variables)
        status = response.code.to_i

        if status == 429
          retry_after = parse_retry_after(response["Retry-After"])
          if attempt < @max_retries
            attempt += 1
            sleep(retry_after || backoff(attempt))
            next
          end
          msg = extract_message(response, "rate limited")
          raise RateLimitError.new(msg, 429, retry_after: retry_after,
                                   extensions: extract_extensions(response))
        end

        if status >= 500
          if attempt < @max_retries
            attempt += 1
            sleep(backoff(attempt))
            next
          end
          msg = extract_message(response, "server error")
          raise ServerError.new(msg, status, extensions: extract_extensions(response))
        end

        return handle_response(response, status)
      end
    end

    private

    def do_request(uri, query, variables)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = @open_timeout
      http.read_timeout = @read_timeout

      request = Net::HTTP::Post.new(uri.path)
      request["Content-Type"] = "application/json"
      request["User-Agent"] = "hivehook-ruby/#{Hivehook::VERSION}"
      request["Authorization"] = "Bearer #{@api_key}" if @api_key

      request.body = JSON.generate({ query: query, variables: variables })
      http.request(request)
    end

    def handle_response(response, status)
      if status == 401
        msg = extract_message(response, "unauthorized")
        raise AuthError.new(msg, 401, extensions: extract_extensions(response))
      end

      if status >= 400
        msg = extract_message(response, response.body)
        raise APIError.new(msg, status, extensions: extract_extensions(response))
      end

      begin
        json = JSON.parse(response.body)
      rescue JSON::ParserError => e
        raise APIError.new("malformed JSON response: #{e.message}", status)
      end

      if json["errors"]&.any?
        err = json["errors"][0]
        ext = err["extensions"]
        code = ext.is_a?(Hash) ? ext["code"] : nil
        msg = err["message"]

        case code
        when "UNAUTHENTICATED", "UNAUTHORIZED"
          raise AuthError.new(msg, 401, extensions: ext, graphql_code: code)
        when "NOT_FOUND"
          raise NotFoundError.new(msg, status, extensions: ext, graphql_code: code)
        when "CONFLICT"
          raise ConflictError.new(msg, status, extensions: ext, graphql_code: code)
        when "VALIDATION", "BAD_USER_INPUT"
          raise ValidationError.new(msg, status, extensions: ext, graphql_code: code)
        else
          raise APIError.new(msg, status, extensions: ext, graphql_code: code)
        end
      end

      raise APIError.new("empty response data", 500) unless json["data"]

      json["data"]
    end

    def extract_message(response, fallback)
      json = JSON.parse(response.body)
      json.dig("errors", 0, "message") || json["message"] || fallback
    rescue JSON::ParserError
      fallback
    end

    def extract_extensions(response)
      json = JSON.parse(response.body)
      json.dig("errors", 0, "extensions")
    rescue JSON::ParserError
      nil
    end

    # Parse Retry-After header. RFC 7231 allows seconds or HTTP-date.
    # Returns Float seconds, or nil if unparseable.
    def parse_retry_after(value)
      return nil if value.nil? || value.empty?
      if value =~ /\A\d+(\.\d+)?\z/
        value.to_f
      else
        begin
          t = Time.httpdate(value)
          [t.to_f - Time.now.to_f, 0.0].max
        rescue ArgumentError
          nil
        end
      end
    end

    def backoff(attempt)
      # 0.1s, 0.2s, 0.4s, ...
      0.1 * (2**(attempt - 1))
    end
  end
end
