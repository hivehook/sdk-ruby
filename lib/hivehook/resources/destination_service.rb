# frozen_string_literal: true

module Hivehook
  module Resources
    class DestinationService < BaseService
      FRAGMENT = "id name url signingSecret status type typeConfig timeoutMs rateLimitRps headers authType deliveryMode ordered blockedDeliveryId healthScore disabledReason healthConfig { windowHours disableBelow } outputFormat createdAt"

      def list(options = {})
        query = "query($status: DestinationStatus, $search: String, $limit: Int, $offset: Int, $after: String, $first: Int) {
          destinations(status: $status, search: $search, limit: $limit, offset: $offset, after: $after, first: $first) {
            nodes { #{FRAGMENT} }
            pageInfo { total limit offset endCursor hasNextPage }
          }
        }"
        @transport.execute(query, build_variables(options, %w[status search limit offset after first]))["destinations"]
      end

      def get(id)
        query = "query($id: UUID!) { destination(id: $id) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id })["destination"]
      end

      def create(input)
        query = "mutation($input: CreateDestinationInput!) { createDestination(input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "input" => input })["createDestination"]
      end

      def update(id, input)
        query = "mutation($id: UUID!, $input: UpdateDestinationInput!) { updateDestination(id: $id, input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id, "input" => input })["updateDestination"]
      end

      def delete(id)
        query = "mutation($id: UUID!) { deleteDestination(id: $id) }"
        @transport.execute(query, { "id" => id })["deleteDestination"]
      end

      def rotate_secret(id)
        query = "mutation($id: UUID!) { rotateDestinationSecret(id: $id) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id })["rotateDestinationSecret"]
      end
    end
  end
end
