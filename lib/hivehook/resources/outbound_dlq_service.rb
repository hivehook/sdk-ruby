# frozen_string_literal: true

module Hivehook
  module Resources
    class OutboundDLQService < BaseService
      FRAGMENT = "id deliveryId messageId lastError replayedAt createdAt"

      def list(options = {})
        query = "query($messageId: UUID, $replayed: Boolean, $search: String, $limit: Int, $offset: Int, $after: String, $first: Int) {
          outboundDlqEntries(messageId: $messageId, replayed: $replayed, search: $search, limit: $limit, offset: $offset, after: $after, first: $first) {
            nodes { #{FRAGMENT} }
            pageInfo { total limit offset endCursor hasNextPage }
          }
        }"
        @transport.execute(query, build_variables(options, %w[messageId replayed search limit offset after first]))["outboundDlqEntries"]
      end

      def get(id)
        query = "query($id: UUID!) { outboundDlqEntry(id: $id) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id })["outboundDlqEntry"]
      end

      def replay(id)
        query = "mutation($id: UUID!) { replayOutboundDlqEntry(id: $id) }"
        @transport.execute(query, { "id" => id })["replayOutboundDlqEntry"]
      end

      def replay_all
        query = "mutation { replayAllOutboundDlq { deliveries } }"
        @transport.execute(query)["replayAllOutboundDlq"]
      end

      def purge(older_than)
        query = "mutation($olderThan: String!) { purgeOutboundDlq(olderThan: $olderThan) { purged } }"
        @transport.execute(query, { "olderThan" => older_than })["purgeOutboundDlq"]
      end
    end
  end
end
