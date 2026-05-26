# frozen_string_literal: true

module Hivehook
  module Resources
    class StreamConsumerService < BaseService
      FRAGMENT = "id streamId name cursorSequence createdAt updatedAt"

      def list(stream_id, options = {})
        query = "query($streamId: UUID!, $search: String, $limit: Int, $offset: Int, $after: String, $first: Int) {
          streamConsumers(streamId: $streamId, search: $search, limit: $limit, offset: $offset, after: $after, first: $first) {
            nodes { #{FRAGMENT} }
            pageInfo { total limit offset endCursor hasNextPage }
          }
        }"
        vars = { "streamId" => stream_id }.merge(build_variables(options, %w[search limit offset after first]))
        @transport.execute(query, vars)["streamConsumers"]
      end

      def get(id)
        query = "query($id: UUID!) { streamConsumer(id: $id) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id })["streamConsumer"]
      end

      def create(input)
        query = "mutation($input: CreateStreamConsumerInput!) { createStreamConsumer(input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "input" => input })["createStreamConsumer"]
      end

      def delete(id)
        query = "mutation($id: UUID!) { deleteStreamConsumer(id: $id) }"
        @transport.execute(query, { "id" => id })["deleteStreamConsumer"]
      end

      def advance_cursor(id, sequence)
        query = "mutation($id: UUID!, $sequence: Int!) { advanceConsumerCursor(id: $id, sequence: $sequence) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id, "sequence" => sequence })["advanceConsumerCursor"]
      end
    end
  end
end
