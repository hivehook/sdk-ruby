# frozen_string_literal: true

module Hivehook
  module Resources
    class APIKeyService < BaseService
      FRAGMENT = "id name keyPrefix scopes sourceIds createdAt expiresAt revokedAt lastUsedAt"

      def list(options = {})
        query = "query($search: String, $limit: Int, $offset: Int) {
          apiKeys(search: $search, limit: $limit, offset: $offset) {
            nodes { #{FRAGMENT} }
            pageInfo { total limit offset endCursor hasNextPage }
          }
        }"
        @transport.execute(query, build_variables(options, %w[search limit offset]))["apiKeys"]
      end

      def get(id)
        query = "query($id: UUID!) { apiKey(id: $id) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id })["apiKey"]
      end

      def create(input)
        query = "mutation($input: CreateAPIKeyInput!) { createAPIKey(input: $input) { apiKey { #{FRAGMENT} } rawKey } }"
        @transport.execute(query, { "input" => input })["createAPIKey"]
      end

      def revoke(id)
        query = "mutation($id: UUID!) { revokeAPIKey(id: $id) }"
        @transport.execute(query, { "id" => id })["revokeAPIKey"]
      end
    end
  end
end
