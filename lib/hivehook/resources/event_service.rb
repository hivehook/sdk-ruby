# frozen_string_literal: true

module Hivehook
  module Resources
    class EventService < BaseService
      FRAGMENT = "id sourceId idempotencyKey eventType rawBody status receivedAt"

      def list(options = {})
        query = "query($sourceId: UUID, $eventType: String, $status: EventStatus, $search: String, $limit: Int, $offset: Int, $after: String, $first: Int) {
          events(sourceId: $sourceId, eventType: $eventType, status: $status, search: $search, limit: $limit, offset: $offset, after: $after, first: $first) {
            nodes { #{FRAGMENT} }
            pageInfo { total limit offset endCursor hasNextPage }
          }
        }"
        @transport.execute(query, build_variables(options, %w[sourceId eventType status search limit offset after first]))["events"]
      end

      def get(id)
        query = "query($id: UUID!) { event(id: $id) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id })["event"]
      end
    end
  end
end
