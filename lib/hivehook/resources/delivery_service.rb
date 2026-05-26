# frozen_string_literal: true

module Hivehook
  module Resources
    class DeliveryService < BaseService
      FRAGMENT = "id eventId subscriptionId destinationId status attempts maxAttempts nextAttemptAt createdAt"

      def list(options = {})
        query = "query($eventId: UUID, $destinationId: UUID, $subscriptionId: UUID, $status: DeliveryStatus, $search: String, $limit: Int, $offset: Int, $after: String, $first: Int) {
          deliveries(eventId: $eventId, destinationId: $destinationId, subscriptionId: $subscriptionId, status: $status, search: $search, limit: $limit, offset: $offset, after: $after, first: $first) {
            nodes { #{FRAGMENT} }
            pageInfo { total limit offset endCursor hasNextPage }
          }
        }"
        @transport.execute(query, build_variables(options, %w[eventId destinationId subscriptionId status search limit offset after first]))["deliveries"]
      end

      def get(id)
        query = "query($id: UUID!) { delivery(id: $id) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id })["delivery"]
      end
    end
  end
end
