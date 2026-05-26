# frozen_string_literal: true

module Hivehook
  module Resources
    class ApplicationService < BaseService
      FRAGMENT = "id name uid createdAt"

      def list(options = {})
        query = "query($search: String, $limit: Int, $offset: Int, $after: String, $first: Int) {
          applications(search: $search, limit: $limit, offset: $offset, after: $after, first: $first) {
            nodes { #{FRAGMENT} }
            pageInfo { total limit offset endCursor hasNextPage }
          }
        }"
        @transport.execute(query, build_variables(options, %w[search limit offset after first]))["applications"]
      end

      def get(id)
        query = "query($id: UUID!) { application(id: $id) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id })["application"]
      end

      def create(input)
        query = "mutation($input: CreateApplicationInput!) { createApplication(input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "input" => input })["createApplication"]
      end

      def update(id, input)
        query = "mutation($id: UUID!, $input: UpdateApplicationInput!) { updateApplication(id: $id, input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id, "input" => input })["updateApplication"]
      end

      def delete(id)
        query = "mutation($id: UUID!) { deleteApplication(id: $id) }"
        @transport.execute(query, { "id" => id })["deleteApplication"]
      end
    end
  end
end
