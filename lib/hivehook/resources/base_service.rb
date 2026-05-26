# frozen_string_literal: true

module Hivehook
  module Resources
    class BaseService
      def initialize(transport)
        @transport = transport
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
