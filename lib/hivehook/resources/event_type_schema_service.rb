# frozen_string_literal: true

module Hivehook
  module Resources
    class EventTypeSchemaService < BaseService
      FRAGMENT = "id eventType description schema example createdAt updatedAt"

      def list(options = {})
        query = "query($search: String, $limit: Int, $offset: Int, $after: String, $first: Int) {
          eventTypeSchemas(search: $search, limit: $limit, offset: $offset, after: $after, first: $first) {
            nodes { #{FRAGMENT} }
            pageInfo { total limit offset endCursor hasNextPage }
          }
        }"
        @transport.execute(query, build_variables(options, %w[search limit offset after first]))["eventTypeSchemas"]
      end

      def get(id)
        query = "query($id: UUID!) { eventTypeSchema(id: $id) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id })["eventTypeSchema"]
      end

      def create(input)
        query = "mutation($input: CreateEventTypeSchemaInput!) { createEventTypeSchema(input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "input" => input })["createEventTypeSchema"]
      end

      def update(id, input)
        query = "mutation($id: UUID!, $input: UpdateEventTypeSchemaInput!) { updateEventTypeSchema(id: $id, input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "id" => id, "input" => input })["updateEventTypeSchema"]
      end

      def delete(id)
        query = "mutation($id: UUID!) { deleteEventTypeSchema(id: $id) }"
        @transport.execute(query, { "id" => id })["deleteEventTypeSchema"]
      end
    end
  end
end
