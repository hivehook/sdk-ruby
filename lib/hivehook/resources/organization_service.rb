# frozen_string_literal: true

module Hivehook
  module Resources
    class OrganizationService < BaseService
      FRAGMENT = "id name slug ssoEnabled ssoProvider retentionEvents retentionMessages otlpConfig { endpoint headers insecure sampleRate } createdAt updatedAt"

      def list(options = {})
        query = "query($search: String, $limit: Int, $offset: Int) {
          organizations(search: $search, limit: $limit, offset: $offset) {
            nodes { #{FRAGMENT} }
            pageInfo { total limit offset endCursor hasNextPage }
          }
        }"
        @transport.execute(query, build_variables(options, %w[search limit offset]))["organizations"]
      end

      def get(id)
        query = "query($id: UUID!) { organization(id: $id) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id })["organization"]
      end

      def create(input)
        query = "mutation($input: CreateOrganizationInput!) { createOrganization(input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "input" => input })["createOrganization"]
      end

      def update(id, input)
        query = "mutation($id: UUID!, $input: UpdateOrganizationInput!) { updateOrganization(id: $id, input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id, "input" => input })["updateOrganization"]
      end

      def delete(id)
        query = "mutation($id: UUID!) { deleteOrganization(id: $id) }"
        @transport.execute(query, { "id" => id })["deleteOrganization"]
      end

      def configure_sso(organization_id, input)
        query = "mutation($organizationId: UUID!, $input: SSOConfigInput!) { configureSSO(organizationId: $organizationId, input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "organizationId" => organization_id, "input" => input })["configureSSO"]
      end

      def disable_sso(organization_id)
        query = "mutation($organizationId: UUID!) { disableSSO(organizationId: $organizationId) { #{FRAGMENT} } }"
        @transport.execute(query, { "organizationId" => organization_id })["disableSSO"]
      end

      def update_retention(organization_id, input)
        query = "mutation($organizationId: UUID!, $input: RetentionInput!) { updateOrganizationRetention(organizationId: $organizationId, input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "organizationId" => organization_id, "input" => input })["updateOrganizationRetention"]
      end

      def delete_data(organization_id)
        query = "mutation($organizationId: UUID!) { deleteOrganizationData(organizationId: $organizationId) }"
        @transport.execute(query, { "organizationId" => organization_id })["deleteOrganizationData"]
      end

      def export_data(organization_id)
        query = "mutation($organizationId: UUID!) { exportOrganizationData(organizationId: $organizationId) }"
        @transport.execute(query, { "organizationId" => organization_id })["exportOrganizationData"]
      end

      def configure_otlp(organization_id, input)
        query = "mutation($organizationId: UUID!, $input: OTLPConfigInput!) { configureOTLP(organizationId: $organizationId, input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "organizationId" => organization_id, "input" => input })["configureOTLP"]
      end

      def disable_otlp(organization_id)
        query = "mutation($organizationId: UUID!) { disableOTLP(organizationId: $organizationId) { #{FRAGMENT} } }"
        @transport.execute(query, { "organizationId" => organization_id })["disableOTLP"]
      end
    end
  end
end
