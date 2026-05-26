# frozen_string_literal: true

module Hivehook
  module Resources
    class AlertRuleService < BaseService
      FRAGMENT = "id name conditionType threshold webhookUrl channel emailConfig { to subjectTemplate } slackConfig { webhookUrl channel } cooldown enabled createdAt"

      def list(options = {})
        query = "query($enabled: Boolean, $search: String, $limit: Int, $offset: Int, $after: String, $first: Int) {
          alertRules(enabled: $enabled, search: $search, limit: $limit, offset: $offset, after: $after, first: $first) {
            nodes { #{FRAGMENT} }
            pageInfo { total limit offset endCursor hasNextPage }
          }
        }"
        @transport.execute(query, build_variables(options, %w[enabled search limit offset after first]))["alertRules"]
      end

      def get(id)
        query = "query($id: UUID!) { alertRule(id: $id) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id })["alertRule"]
      end

      def create(input)
        query = "mutation($input: CreateAlertRuleInput!) { createAlertRule(input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "input" => input })["createAlertRule"]
      end

      def update(id, input)
        query = "mutation($id: UUID!, $input: UpdateAlertRuleInput!) { updateAlertRule(id: $id, input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id, "input" => input })["updateAlertRule"]
      end

      def delete(id)
        query = "mutation($id: UUID!) { deleteAlertRule(id: $id) }"
        @transport.execute(query, { "id" => id })["deleteAlertRule"]
      end

      def test(id)
        query = "mutation($id: UUID!) { testAlertRule(id: $id) }"
        @transport.execute(query, { "id" => id })["testAlertRule"]
      end
    end
  end
end
