# frozen_string_literal: true

require_relative "test_helper"

class ClientTest < Minitest::Test
  def test_client_has_all_services
    client = Hivehook::Client.new
    assert_kind_of Hivehook::Resources::SourceService, client.sources
    assert_kind_of Hivehook::Resources::DestinationService, client.destinations
    assert_kind_of Hivehook::Resources::SubscriptionService, client.subscriptions
    assert_kind_of Hivehook::Resources::EventService, client.events
    assert_kind_of Hivehook::Resources::DeliveryService, client.deliveries
    assert_kind_of Hivehook::Resources::DLQService, client.dlq
    assert_kind_of Hivehook::Resources::APIKeyService, client.api_keys
    assert_kind_of Hivehook::Resources::AlertRuleService, client.alert_rules
    assert_kind_of Hivehook::Resources::BookmarkService, client.bookmarks
    assert_kind_of Hivehook::Resources::EventTypeSchemaService, client.event_type_schemas
    assert_kind_of Hivehook::Resources::ApplicationService, client.applications
    assert_kind_of Hivehook::Resources::EndpointService, client.endpoints
    assert_kind_of Hivehook::Resources::MessageService, client.messages
    assert_kind_of Hivehook::Resources::OutboundDeliveryService, client.outbound_deliveries
    assert_kind_of Hivehook::Resources::OutboundDLQService, client.outbound_dlq
    assert_kind_of Hivehook::Resources::StatusService, client.status
    assert_kind_of Hivehook::Resources::TransformationService, client.transformations
    assert_kind_of Hivehook::Resources::PortalService, client.portal
    assert_kind_of Hivehook::Resources::StreamService, client.streams
    assert_kind_of Hivehook::Resources::StreamConsumerService, client.stream_consumers
    assert_kind_of Hivehook::Resources::StreamSinkService, client.stream_sinks
    assert_kind_of Hivehook::Resources::OrganizationService, client.organizations
    assert_kind_of Hivehook::Resources::UserService, client.users
    assert_kind_of Hivehook::Resources::AuditLogService, client.audit_logs
  end
end
