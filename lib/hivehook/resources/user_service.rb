# frozen_string_literal: true

module Hivehook
  module Resources
    class UserService < BaseService
      FRAGMENT = "id organizationId email name role lastLoginAt createdAt updatedAt"

      def list(options = {})
        query = "query($organizationId: UUID, $search: String, $limit: Int, $offset: Int) {
          users(organizationId: $organizationId, search: $search, limit: $limit, offset: $offset) {
            nodes { #{FRAGMENT} }
            pageInfo { total limit offset endCursor hasNextPage }
          }
        }"
        @transport.execute(query, build_variables(options, %w[organizationId search limit offset]))["users"]
      end

      def me
        query = "query { me { #{FRAGMENT} } }"
        @transport.execute(query, {})["me"]
      end

      def invite(organization_id, input)
        query = "mutation($organizationId: UUID!, $input: InviteUserInput!) { inviteUser(organizationId: $organizationId, input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "organizationId" => organization_id, "input" => input })["inviteUser"]
      end

      def remove(id)
        query = "mutation($id: UUID!) { removeUser(id: $id) }"
        @transport.execute(query, { "id" => id })["removeUser"]
      end

      def update_role(id, input)
        query = "mutation($id: UUID!, $input: UpdateUserRoleInput!) { updateUserRole(id: $id, input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id, "input" => input })["updateUserRole"]
      end
    end
  end
end
