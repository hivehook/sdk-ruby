# frozen_string_literal: true

module Hivehook
  class HivehookError < StandardError; end

  class APIError < HivehookError
    attr_reader :status_code, :extensions, :graphql_code

    def initialize(message, status_code = nil, extensions: nil, graphql_code: nil)
      super(message)
      @status_code = status_code
      @extensions = extensions
      @graphql_code = graphql_code
    end
  end

  class AuthError < APIError
    def initialize(message = "unauthorized", status_code = 401, extensions: nil, graphql_code: nil)
      super(message, status_code, extensions: extensions, graphql_code: graphql_code)
    end
  end

  class NotFoundError < APIError; end
  class ConflictError < APIError; end
  class ValidationError < APIError; end
  class ServerError < APIError; end

  class RateLimitError < APIError
    attr_reader :retry_after

    def initialize(message, status_code = 429, retry_after: nil, extensions: nil, graphql_code: nil)
      super(message, status_code, extensions: extensions, graphql_code: graphql_code)
      @retry_after = retry_after
    end
  end
end
