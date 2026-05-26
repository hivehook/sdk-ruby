# frozen_string_literal: true

module Hivehook
  module Resources
    class TransformationService < BaseService
      FRAGMENT = "id name description code enabled failOpen timeoutMs createdAt updatedAt"

      def list(options = {})
        query = "query($enabled: Boolean, $search: String, $limit: Int, $offset: Int, $after: String, $first: Int) {
          transformations(enabled: $enabled, search: $search, limit: $limit, offset: $offset, after: $after, first: $first) {
            nodes { #{FRAGMENT} }
            pageInfo { total limit offset endCursor hasNextPage }
          }
        }"
        @transport.execute(query, build_variables(options, %w[enabled search limit offset after first]))["transformations"]
      end

      def get(id)
        query = "query($id: UUID!) { transformation(id: $id) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id })["transformation"]
      end

      def create(input)
        query = "mutation($input: CreateTransformationInput!) { createTransformation(input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "input" => input })["createTransformation"]
      end

      def update(id, input)
        query = "mutation($id: UUID!, $input: UpdateTransformationInput!) { updateTransformation(id: $id, input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id, "input" => input })["updateTransformation"]
      end

      def delete(id)
        query = "mutation($id: UUID!) { deleteTransformation(id: $id) }"
        @transport.execute(query, { "id" => id })["deleteTransformation"]
      end

      def test(input)
        query = "mutation($input: TestTransformationInput!) { testTransformation(input: $input) { success output error durationMs } }"
        @transport.execute(query, { "input" => input })["testTransformation"]
      end
    end
  end
end
