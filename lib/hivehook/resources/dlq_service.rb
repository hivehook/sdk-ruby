# frozen_string_literal: true

module Hivehook
  module Resources
    class DLQService < BaseService
      FRAGMENT = "id deliveryId eventId lastError replayedAt createdAt"

      def list(options = {})
        query = "query($eventId: UUID, $replayed: Boolean, $search: String, $limit: Int, $offset: Int, $after: String, $first: Int) {
          dlqEntries(eventId: $eventId, replayed: $replayed, search: $search, limit: $limit, offset: $offset, after: $after, first: $first) {
            nodes { #{FRAGMENT} }
            pageInfo { total limit offset endCursor hasNextPage }
          }
        }"
        @transport.execute(query, build_variables(options, %w[eventId replayed search limit offset after first]))["dlqEntries"]
      end

      def get(id)
        query = "query($id: UUID!) { dlqEntry(id: $id) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id })["dlqEntry"]
      end

      def replay(id)
        query = "mutation($id: UUID!) { replayDLQEntry(id: $id) }"
        @transport.execute(query, { "id" => id })["replayDLQEntry"]
      end

      def replay_all
        query = "mutation { replayAllDLQ { deliveries } }"
        @transport.execute(query)["replayAllDLQ"]
      end

      def purge(older_than)
        query = "mutation($olderThan: String!) { purgeDLQ(olderThan: $olderThan) { purged } }"
        @transport.execute(query, { "olderThan" => older_than })["purgeDLQ"]
      end
    end
  end
end
