# frozen_string_literal: true

module Hivehook
  module Resources
    class MetaEventConfigService < BaseService
      FRAGMENT = "id name url signingSecret eventTypes enabled createdAt"

      def list(options = {})
        query = "query($search: String, $limit: Int, $offset: Int, $after: String, $first: Int) {
          metaEventConfigs(search: $search, limit: $limit, offset: $offset, after: $after, first: $first) {
            nodes { #{FRAGMENT} }
            pageInfo { total limit offset endCursor hasNextPage }
          }
        }"
        @transport.execute(query, build_variables(options, %w[search limit offset after first]))["metaEventConfigs"]
      end

      def get(id)
        query = "query($id: UUID!) { metaEventConfig(id: $id) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id })["metaEventConfig"]
      end

      def create(input)
        query = "mutation($input: CreateMetaEventConfigInput!) { createMetaEventConfig(input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "input" => input })["createMetaEventConfig"]
      end

      def update(id, input)
        query = "mutation($id: UUID!, $input: UpdateMetaEventConfigInput!) { updateMetaEventConfig(id: $id, input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id, "input" => input })["updateMetaEventConfig"]
      end

      def delete(id)
        query = "mutation($id: UUID!) { deleteMetaEventConfig(id: $id) }"
        @transport.execute(query, { "id" => id })["deleteMetaEventConfig"]
      end
    end
  end
end
