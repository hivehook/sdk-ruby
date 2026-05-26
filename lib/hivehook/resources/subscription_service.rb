# frozen_string_literal: true

module Hivehook
  module Resources
    class SubscriptionService < BaseService
      FRAGMENT = "id name sourceId destinationId filterConfig enabled createdAt"

      def list(options = {})
        query = "query($sourceId: UUID, $destinationId: UUID, $enabled: Boolean, $search: String, $limit: Int, $offset: Int, $after: String, $first: Int) {
          subscriptions(sourceId: $sourceId, destinationId: $destinationId, enabled: $enabled, search: $search, limit: $limit, offset: $offset, after: $after, first: $first) {
            nodes { #{FRAGMENT} }
            pageInfo { total limit offset endCursor hasNextPage }
          }
        }"
        @transport.execute(query, build_variables(options, %w[sourceId destinationId enabled search limit offset after first]))["subscriptions"]
      end

      def get(id)
        query = "query($id: UUID!) { subscription(id: $id) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id })["subscription"]
      end

      def create(input)
        query = "mutation($input: CreateSubscriptionInput!) { createSubscription(input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "input" => input })["createSubscription"]
      end

      def update(id, input)
        query = "mutation($id: UUID!, $input: UpdateSubscriptionInput!) { updateSubscription(id: $id, input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id, "input" => input })["updateSubscription"]
      end

      def delete(id)
        query = "mutation($id: UUID!) { deleteSubscription(id: $id) }"
        @transport.execute(query, { "id" => id })["deleteSubscription"]
      end
    end
  end
end
