# frozen_string_literal: true

module Hivehook
  module Resources
    class SourceService < BaseService
      FRAGMENT = "id name slug providerType verifyConfig status rateLimitRps spikeProtection maxIngestRps brokerConfig responseConfig { statusCode body contentType } dedupConfig { strategy fields window } createdAt"

      def list(options = {})
        query = "query($status: SourceStatus, $providerType: String, $search: String, $limit: Int, $offset: Int, $after: String, $first: Int) {
          sources(status: $status, providerType: $providerType, search: $search, limit: $limit, offset: $offset, after: $after, first: $first) {
            nodes { #{FRAGMENT} }
            pageInfo { total limit offset endCursor hasNextPage }
          }
        }"
        @transport.execute(query, build_variables(options, %w[status providerType search limit offset after first]))["sources"]
      end

      def get(id)
        query = "query($id: UUID!) { source(id: $id) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id })["source"]
      end

      def create(input)
        query = "mutation($input: CreateSourceInput!) { createSource(input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "input" => input })["createSource"]
      end

      def update(id, input)
        query = "mutation($id: UUID!, $input: UpdateSourceInput!) { updateSource(id: $id, input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id, "input" => input })["updateSource"]
      end

      def delete(id)
        query = "mutation($id: UUID!) { deleteSource(id: $id) }"
        @transport.execute(query, { "id" => id })["deleteSource"]
      end

      def rotate_secret(id)
        query = "mutation($id: UUID!) { rotateSourceSecret(id: $id) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id })["rotateSourceSecret"]
      end

      def clear_secondary_secret(id)
        query = "mutation($id: UUID!) { clearSourceSecondarySecret(id: $id) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id })["clearSourceSecondarySecret"]
      end
    end
  end
end
