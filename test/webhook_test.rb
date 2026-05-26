# frozen_string_literal: true

require_relative "test_helper"

class WebhookTest < Minitest::Test
  SECRET = "whsec_test123"
  PAYLOAD = '{"event":"test"}'

  def test_header_constants
    assert_equal "X-Hivehook-Signature", Hivehook::Webhook::HEADER_SIGNATURE
    assert_equal "X-Hivehook-Timestamp", Hivehook::Webhook::HEADER_TIMESTAMP
    assert_equal "X-Hivehook-Message-ID", Hivehook::Webhook::HEADER_MESSAGE_ID
  end

  def test_sign
    sig = Hivehook::Webhook.sign(PAYLOAD, SECRET, 1700000000)
    assert_match(/\Av1=[a-f0-9]{64}\z/, sig)
  end

  def test_deterministic
    sig1 = Hivehook::Webhook.sign(PAYLOAD, SECRET, 1700000000)
    sig2 = Hivehook::Webhook.sign(PAYLOAD, SECRET, 1700000000)
    assert_equal sig1, sig2
  end

  def test_different_secrets
    sig1 = Hivehook::Webhook.sign(PAYLOAD, SECRET, 1700000000)
    sig2 = Hivehook::Webhook.sign(PAYLOAD, "different", 1700000000)
    refute_equal sig1, sig2
  end

  def test_verify_valid
    ts = Time.now.to_i
    sig = Hivehook::Webhook.sign(PAYLOAD, SECRET, ts)
    assert Hivehook::Webhook.verify(PAYLOAD, SECRET, sig, ts, 300)
  end

  def test_reject_wrong_secret
    ts = Time.now.to_i
    sig = Hivehook::Webhook.sign(PAYLOAD, SECRET, ts)
    refute Hivehook::Webhook.verify(PAYLOAD, "wrong", sig, ts, 300)
  end

  def test_reject_expired
    ts = Time.now.to_i - 600
    sig = Hivehook::Webhook.sign(PAYLOAD, SECRET, ts)
    refute Hivehook::Webhook.verify(PAYLOAD, SECRET, sig, ts, 300)
  end

  def test_skip_timestamp_check_when_nil
    ts = Time.now.to_i - 600
    sig = Hivehook::Webhook.sign(PAYLOAD, SECRET, ts)
    assert Hivehook::Webhook.verify(PAYLOAD, SECRET, sig, ts)
    assert Hivehook::Webhook.verify(PAYLOAD, SECRET, sig, ts, nil)
  end

  # tolerance_seconds == 0 means strict: any drift fails.
  def test_tolerance_zero_strict_rejects_past_drift
    ts = Time.now.to_i - 5
    sig = Hivehook::Webhook.sign(PAYLOAD, SECRET, ts)
    refute Hivehook::Webhook.verify(PAYLOAD, SECRET, sig, ts, 0)
  end

  def test_tolerance_zero_strict_rejects_future_drift
    ts = Time.now.to_i + 5
    sig = Hivehook::Webhook.sign(PAYLOAD, SECRET, ts)
    refute Hivehook::Webhook.verify(PAYLOAD, SECRET, sig, ts, 0)
  end

  # Future timestamps beyond tolerance must be rejected (clock-skew / replay).
  def test_reject_future_timestamp_beyond_tolerance
    ts = Time.now.to_i + 600
    sig = Hivehook::Webhook.sign(PAYLOAD, SECRET, ts)
    refute Hivehook::Webhook.verify(PAYLOAD, SECRET, sig, ts, 300)
  end

  def test_accept_future_timestamp_within_tolerance
    ts = Time.now.to_i + 60
    sig = Hivehook::Webhook.sign(PAYLOAD, SECRET, ts)
    assert Hivehook::Webhook.verify(PAYLOAD, SECRET, sig, ts, 300)
  end

  def test_rotation_primary
    ts = Time.now.to_i
    sig = Hivehook::Webhook.sign(PAYLOAD, "primary", ts)
    assert Hivehook::Webhook.verify_with_rotation(PAYLOAD, "primary", "secondary", sig, ts, 300)
  end

  def test_rotation_secondary
    ts = Time.now.to_i
    sig = Hivehook::Webhook.sign(PAYLOAD, "secondary", ts)
    assert Hivehook::Webhook.verify_with_rotation(PAYLOAD, "primary", "secondary", sig, ts, 300)
  end

  def test_rotation_reject
    ts = Time.now.to_i
    refute Hivehook::Webhook.verify_with_rotation(PAYLOAD, "primary", "secondary", "v1=bad", ts, 300)
  end

  def test_rotation_with_nil_secondary
    ts = Time.now.to_i
    sig = Hivehook::Webhook.sign(PAYLOAD, "primary", ts)
    assert Hivehook::Webhook.verify_with_rotation(PAYLOAD, "primary", nil, sig, ts, 300)
  end

  # Multi-scheme: comma-separated list, pick v1=
  def test_multi_scheme_signature
    ts = Time.now.to_i
    v1 = Hivehook::Webhook.sign(PAYLOAD, SECRET, ts) # "v1=..."
    header = "t=#{ts},#{v1},v2=somethingelse"
    assert Hivehook::Webhook.verify(PAYLOAD, SECRET, header, ts, 300)
  end

  def test_multi_scheme_signature_with_whitespace
    ts = Time.now.to_i
    v1 = Hivehook::Webhook.sign(PAYLOAD, SECRET, ts)
    header = "t=#{ts}, #{v1} , v2=other"
    assert Hivehook::Webhook.verify(PAYLOAD, SECRET, header, ts, 300)
  end

  def test_missing_v1_element_rejected
    ts = Time.now.to_i
    refute Hivehook::Webhook.verify(PAYLOAD, SECRET, "v2=abc,v3=def", ts, 300)
  end

  def test_empty_signature_rejected
    ts = Time.now.to_i
    refute Hivehook::Webhook.verify(PAYLOAD, SECRET, "", ts, 300)
  end
end
