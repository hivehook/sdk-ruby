# frozen_string_literal: true

require_relative "hivehook/version"
require_relative "hivehook/errors"
require_relative "hivehook/transport"
require_relative "hivehook/webhook"
require_relative "hivehook/resources/base_service"
require_relative "hivehook/resources/source_service"
require_relative "hivehook/resources/destination_service"
require_relative "hivehook/resources/subscription_service"
require_relative "hivehook/resources/event_service"
require_relative "hivehook/resources/delivery_service"
require_relative "hivehook/resources/dlq_service"
require_relative "hivehook/resources/api_key_service"
require_relative "hivehook/resources/alert_rule_service"
require_relative "hivehook/resources/bookmark_service"
require_relative "hivehook/resources/event_type_schema_service"
require_relative "hivehook/resources/application_service"
require_relative "hivehook/resources/endpoint_service"
require_relative "hivehook/resources/message_service"
require_relative "hivehook/resources/outbound_delivery_service"
require_relative "hivehook/resources/outbound_dlq_service"
require_relative "hivehook/resources/status_service"
require_relative "hivehook/resources/transformation_service"
require_relative "hivehook/resources/portal_service"
require_relative "hivehook/resources/stream_service"
require_relative "hivehook/resources/stream_consumer_service"
require_relative "hivehook/resources/stream_sink_service"
require_relative "hivehook/resources/organization_service"
require_relative "hivehook/resources/user_service"
require_relative "hivehook/resources/audit_log_service"
require_relative "hivehook/resources/meta_event_config_service"

module Hivehook
  class Client
    attr_reader :sources, :destinations, :subscriptions, :events, :deliveries,
                :dlq, :api_keys, :alert_rules, :bookmarks, :event_type_schemas,
                :applications, :endpoints, :messages, :outbound_deliveries,
                :outbound_dlq, :status, :transformations, :portal,
                :streams, :stream_consumers, :stream_sinks,
                :organizations, :users, :audit_logs, :meta_event_configs

    def initialize(base_url: "http://localhost:8080", api_key: nil,
                   open_timeout: GraphQLTransport::DEFAULT_OPEN_TIMEOUT,
                   read_timeout: GraphQLTransport::DEFAULT_READ_TIMEOUT,
                   max_retries: GraphQLTransport::DEFAULT_MAX_RETRIES)
      transport = GraphQLTransport.new(base_url, api_key,
                                       open_timeout: open_timeout,
                                       read_timeout: read_timeout,
                                       max_retries: max_retries)
      @sources = Resources::SourceService.new(transport)
      @destinations = Resources::DestinationService.new(transport)
      @subscriptions = Resources::SubscriptionService.new(transport)
      @events = Resources::EventService.new(transport)
      @deliveries = Resources::DeliveryService.new(transport)
      @dlq = Resources::DLQService.new(transport)
      @api_keys = Resources::APIKeyService.new(transport)
      @alert_rules = Resources::AlertRuleService.new(transport)
      @bookmarks = Resources::BookmarkService.new(transport)
      @event_type_schemas = Resources::EventTypeSchemaService.new(transport)
      @applications = Resources::ApplicationService.new(transport)
      @endpoints = Resources::EndpointService.new(transport)
      @messages = Resources::MessageService.new(transport)
      @outbound_deliveries = Resources::OutboundDeliveryService.new(transport)
      @outbound_dlq = Resources::OutboundDLQService.new(transport)
      @status = Resources::StatusService.new(transport)
      @transformations = Resources::TransformationService.new(transport)
      @portal = Resources::PortalService.new(transport)
      @streams = Resources::StreamService.new(transport)
      @stream_consumers = Resources::StreamConsumerService.new(transport)
      @stream_sinks = Resources::StreamSinkService.new(transport)
      @organizations = Resources::OrganizationService.new(transport)
      @users = Resources::UserService.new(transport)
      @audit_logs = Resources::AuditLogService.new(transport)
      @meta_event_configs = Resources::MetaEventConfigService.new(transport)
    end
  end
end
