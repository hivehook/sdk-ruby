# frozen_string_literal: true

module Hivehook
  module Resources
    class AuditLogService < BaseService
      FRAGMENT = "id actorType actorId actorName action resourceType resourceId orgId ipAddress userAgent details createdAt"

      def list(options = {})
        query = "query($actorType: String, $resourceType: String, $resourceId: UUID, $action: String, $since: Time, $until: Time, $search: String, $limit: Int, $offset: Int, $after: String, $first: Int) {
          auditLogs(actorType: $actorType, resourceType: $resourceType, resourceId: $resourceId, action: $action, since: $since, until: $until, search: $search, limit: $limit, offset: $offset, after: $after, first: $first) {
            nodes { #{FRAGMENT} }
            pageInfo { total limit offset endCursor hasNextPage }
          }
        }"
        @transport.execute(query, build_variables(options, %w[actorType resourceType resourceId action since until search limit offset after first]))["auditLogs"]
      end

      def get(id)
        query = "query($id: UUID!) { auditLog(id: $id) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id })["auditLog"]
      end
    end
  end
end
