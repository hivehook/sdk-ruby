# frozen_string_literal: true

module Hivehook
  module Resources
    class EndpointService < BaseService
      FRAGMENT = "id applicationId url signingSecret status type typeConfig rateLimitRps timeoutMs headers authType deliveryMode ordered blockedDeliveryId healthScore disabledReason healthConfig { windowHours disableBelow } outputFormat createdAt"

      def list(options = {})
        query = "query($applicationId: UUID, $status: EndpointStatus, $search: String, $limit: Int, $offset: Int, $after: String, $first: Int) {
          endpoints(applicationId: $applicationId, status: $status, search: $search, limit: $limit, offset: $offset, after: $after, first: $first) {
            nodes { #{FRAGMENT} }
            pageInfo { total limit offset endCursor hasNextPage }
          }
        }"
        @transport.execute(query, build_variables(options, %w[applicationId status search limit offset after first]))["endpoints"]
      end

      def get(id)
        query = "query($id: UUID!) { endpoint(id: $id) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id })["endpoint"]
      end

      def create(input)
        query = "mutation($input: CreateEndpointInput!) { createEndpoint(input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "input" => input })["createEndpoint"]
      end

      def update(id, input)
        query = "mutation($id: UUID!, $input: UpdateEndpointInput!) { updateEndpoint(id: $id, input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id, "input" => input })["updateEndpoint"]
      end

      def delete(id)
        query = "mutation($id: UUID!) { deleteEndpoint(id: $id) }"
        @transport.execute(query, { "id" => id })["deleteEndpoint"]
      end

      def rotate_secret(id)
        query = "mutation($id: UUID!) { rotateEndpointSecret(id: $id) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id })["rotateEndpointSecret"]
      end
    end
  end
end
