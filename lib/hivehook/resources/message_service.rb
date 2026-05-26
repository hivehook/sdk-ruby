# frozen_string_literal: true

module Hivehook
  module Resources
    class MessageService < BaseService
      FRAGMENT = "id applicationId eventType payload idempotencyKey status createdAt"

      def list(options = {})
        query = "query($applicationId: UUID, $eventType: String, $status: MessageStatus, $search: String, $limit: Int, $offset: Int, $after: String, $first: Int) {
          messages(applicationId: $applicationId, eventType: $eventType, status: $status, search: $search, limit: $limit, offset: $offset, after: $after, first: $first) {
            nodes { #{FRAGMENT} }
            pageInfo { total limit offset endCursor hasNextPage }
          }
        }"
        @transport.execute(query, build_variables(options, %w[applicationId eventType status search limit offset after first]))["messages"]
      end

      def get(id)
        query = "query($id: UUID!) { message(id: $id) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id })["message"]
      end

      def send(input)
        query = "mutation($input: SendMessageInput!) { sendMessage(input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "input" => input })["sendMessage"]
      end

      def broadcast(input)
        query = "mutation($input: BroadcastMessageInput!) { broadcastMessage(input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "input" => input })["broadcastMessage"]
      end

      def send_dynamic(input)
        query = "mutation($input: SendDynamicMessageInput!) { sendDynamicMessage(input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "input" => input })["sendDynamicMessage"]
      end
    end
  end
end
