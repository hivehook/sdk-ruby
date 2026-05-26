# frozen_string_literal: true

module Hivehook
  module Resources
    class OutboundDeliveryService < BaseService
      FRAGMENT = "id messageId endpointId status attempts maxAttempts nextAttemptAt createdAt"

      def list(options = {})
        query = "query($messageId: UUID, $endpointId: UUID, $status: DeliveryStatus, $search: String, $limit: Int, $offset: Int, $after: String, $first: Int) {
          outboundDeliveries(messageId: $messageId, endpointId: $endpointId, status: $status, search: $search, limit: $limit, offset: $offset, after: $after, first: $first) {
            nodes { #{FRAGMENT} }
            pageInfo { total limit offset endCursor hasNextPage }
          }
        }"
        @transport.execute(query, build_variables(options, %w[messageId endpointId status search limit offset after first]))["outboundDeliveries"]
      end

      def get(id)
        query = "query($id: UUID!) { outboundDelivery(id: $id) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id })["outboundDelivery"]
      end
    end
  end
end
