# frozen_string_literal: true

module Hivehook
  module Resources
    class StreamSinkService < BaseService
      FRAGMENT = "id streamId name sinkType config batchSize flushInterval cursorSequence status lastFlushedAt createdAt"

      def list(stream_id, options = {})
        query = "query($streamId: UUID!, $status: SinkStatus, $search: String, $limit: Int, $offset: Int, $after: String, $first: Int) {
          streamSinks(streamId: $streamId, status: $status, search: $search, limit: $limit, offset: $offset, after: $after, first: $first) {
            nodes { #{FRAGMENT} }
            pageInfo { total limit offset endCursor hasNextPage }
          }
        }"
        vars = { "streamId" => stream_id }.merge(build_variables(options, %w[status search limit offset after first]))
        @transport.execute(query, vars)["streamSinks"]
      end

      def iterate(stream_id, options = {})
        return enum_for(:iterate, stream_id, options) unless block_given?

        opts = options.dup
        offset = opts[:offset] || 0
        loop do
          opts[:offset] = offset
          conn = list(stream_id, opts)
          nodes = conn["nodes"] || []
          nodes.each { |node| yield node }
          page_info = conn["pageInfo"] || {}
          break if !page_info["hasNextPage"] || nodes.empty?

          offset += nodes.length
        end
      end

      def get(id)
        query = "query($id: UUID!) { streamSink(id: $id) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id })["streamSink"]
      end

      def create(input)
        query = "mutation($input: CreateStreamSinkInput!) { createStreamSink(input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "input" => input })["createStreamSink"]
      end

      def update(id, input)
        query = "mutation($id: UUID!, $input: UpdateStreamSinkInput!) { updateStreamSink(id: $id, input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id, "input" => input })["updateStreamSink"]
      end

      def delete(id)
        query = "mutation($id: UUID!) { deleteStreamSink(id: $id) }"
        @transport.execute(query, { "id" => id })["deleteStreamSink"]
      end
    end
  end
end
