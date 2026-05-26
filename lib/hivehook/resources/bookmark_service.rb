# frozen_string_literal: true

module Hivehook
  module Resources
    class BookmarkService < BaseService
      FRAGMENT = "id eventId name notes createdAt"

      def list(options = {})
        query = "query($eventId: UUID, $search: String, $limit: Int, $offset: Int, $after: String, $first: Int) {
          bookmarks(eventId: $eventId, search: $search, limit: $limit, offset: $offset, after: $after, first: $first) {
            nodes { #{FRAGMENT} }
            pageInfo { total limit offset endCursor hasNextPage }
          }
        }"
        @transport.execute(query, build_variables(options, %w[eventId search limit offset after first]))["bookmarks"]
      end

      def create(input)
        query = "mutation($input: CreateBookmarkInput!) { createBookmark(input: $input) { #{FRAGMENT} } }"
        @transport.execute(query, { "input" => input })["createBookmark"]
      end

      def delete(id)
        query = "mutation($id: UUID!) { deleteBookmark(id: $id) }"
        @transport.execute(query, { "id" => id })["deleteBookmark"]
      end
    end
  end
end
