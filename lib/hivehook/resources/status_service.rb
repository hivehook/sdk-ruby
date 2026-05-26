# frozen_string_literal: true

module Hivehook
  module Resources
    class StatusService < BaseService
      def get
        query = "query { status { status dlqSize outboundDlqSize queueDepth activeWorkers totalWorkers uptime version sourcesTotal destinationsTotal subscriptionsTotal eventsTotal eventsFailed deliveriesTotal deliveriesPending deliveriesDelivered messagesTotal outboundDeliveriesTotal outboundDeliveriesPending outboundDeliveriesFailed } }"
        @transport.execute(query)["status"]
      end
    end
  end
end
