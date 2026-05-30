# frozen_string_literal: true

module Hivehook
  module Resources
    class StreamService < BaseService
      FRAGMENT = "id applicationId name status retentionDays createdAt"

      def list(options = {})
        query = "query($applicationId: UUID, $status: StreamStatus, $search: String, $limit: Int, $offset: Int, $after: String, $first: Int) {
          streams(applicationId: $applicationId, status: $status, search: $search, limit: $limit, offset: $offset, after: $after, first: $first) {
            nodes { #{FRAGMENT} }
            pageInfo { total limit offset endCursor hasNextPage }
          }
        }"
        @transport.execute(query, build_variables(options, %w[applicationId status search limit offset after first]))["streams"]
      end

      def get(id)
        query = "query($id: UUID!) { stream(id: $id) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id })["stream"]
      end

      def create(input)
        query = "mutation($input: CreateStreamInput!) { createStream(input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "input" => input })["createStream"]
      end

      def update(id, input)
        query = "mutation($id: UUID!, $input: UpdateStreamInput!) { updateStream(id: $id, input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id, "input" => input })["updateStream"]
      end

      def delete(id)
        query = "mutation($id: UUID!) { deleteStream(id: $id) }"
        @transport.execute(query, { "id" => id })["deleteStream"]
      end

      ENTRY_FRAGMENT = "id streamId sequence messageId eventType payload createdAt"

      def entries(stream_id, after_sequence: nil, limit: nil)
        query = "query($streamId: UUID!, $afterSequence: Int, $limit: Int) {
          streamEntries(streamId: $streamId, afterSequence: $afterSequence, limit: $limit) {
            nodes { #{ENTRY_FRAGMENT} }
            pageInfo { total limit offset endCursor hasNextPage }
          }
        }"
        vars = { "streamId" => stream_id }
        vars["afterSequence"] = after_sequence unless after_sequence.nil?
        vars["limit"] = limit unless limit.nil?
        @transport.execute(query, vars)["streamEntries"]
      end
    end
  end
end
