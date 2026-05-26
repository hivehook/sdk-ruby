# frozen_string_literal: true

require "openssl"

module Hivehook
  module Webhook
    HEADER_SIGNATURE = "X-Hivehook-Signature"
    HEADER_TIMESTAMP = "X-Hivehook-Timestamp"
    HEADER_MESSAGE_ID = "X-Hivehook-Message-ID"

    def self.sign(payload, secret, timestamp)
      message = "#{timestamp}.#{payload}"
      digest = OpenSSL::HMAC.hexdigest("SHA256", secret, message)
      "v1=#{digest}"
    end

    # Verify a webhook signature.
    #
    # tolerance_seconds semantics:
    #   nil      -> skip timestamp check
    #   0        -> strict, any drift fails
    #   positive -> allow past drift up to N seconds, reject future timestamps beyond N seconds
    def self.verify(payload, secret, signature, timestamp, tolerance_seconds = nil)
      unless tolerance_seconds.nil?
        delta = Time.now.to_i - timestamp
        # delta > 0  -> timestamp is in the past
        # delta < 0  -> timestamp is in the future
        if delta > tolerance_seconds || -delta > tolerance_seconds
          return false
        end
      end

      v1 = extract_v1(signature)
      return false unless v1

      expected = sign(payload, secret, timestamp)
      secure_compare(expected, v1)
    end

    def self.verify_with_rotation(payload, primary, secondary, signature, timestamp, tolerance_seconds = nil)
      # Compute both verifications without short-circuiting to keep
      # timing characteristics uniform regardless of which secret matched.
      primary_ok = verify(payload, primary, signature, timestamp, tolerance_seconds)
      secondary_ok = secondary ? verify(payload, secondary, signature, timestamp, tolerance_seconds) : false
      primary_ok | secondary_ok
    end

    # Parse a multi-scheme signature header value and return the full "v1=..."
    # element, or nil if absent. Supports comma-separated lists like
    # "v1=abc,v2=xyz" or "t=123,v1=abc".
    def self.extract_v1(signature)
      return nil if signature.nil?
      signature.split(",").map(&:strip).find { |part| part.start_with?("v1=") }
    end

    def self.secure_compare(a, b)
      return false unless a.bytesize == b.bytesize
      OpenSSL.fixed_length_secure_compare(a, b)
    end

    private_class_method :secure_compare
  end
end
