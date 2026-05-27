# frozen_string_literal: true

module Hivehook
  module Resources
    class BaseService
      def initialize(transport)
        @transport = transport
      end

      def iterate(options = {})
        return enum_for(:iterate, options) unless block_given?

        opts = options.dup
        offset = opts[:offset] || 0
        loop do
          opts[:offset] = offset
          conn = list(opts)
          nodes = conn["nodes"] || []
          nodes.each { |node| yield node }
          page_info = conn["pageInfo"] || {}
          break if !page_info["hasNextPage"] || nodes.empty?

          offset += nodes.length
        end
      end

      private

      def build_variables(options, allowed)
        vars = {}
        allowed.each do |key|
          sym = key.to_sym
          vars[key] = options[sym] if options.key?(sym)
        end
        vars
      end
    end
  end
end
