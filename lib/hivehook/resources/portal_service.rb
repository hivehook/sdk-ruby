# frozen_string_literal: true

module Hivehook
  module Resources
    class PortalService < BaseService
      def generate_token(application_id)
        query = "mutation($applicationId: UUID!) { generatePortalToken(applicationId: $applicationId) { token expiresAt } }"
        @transport.execute(query, { "applicationId" => application_id })["generatePortalToken"]
      end
    end
  end
end
