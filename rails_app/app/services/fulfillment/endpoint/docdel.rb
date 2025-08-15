# frozen_string_literal: true

module Fulfillment
  class Endpoint
    # Wharton Document Delivery submission endpoint
    class Docdel < Endpoint
      class << self
        # Submit a Request to the Wharton Document Delivery email account
        # @param request [Fulfillment::Request]
        # @return [Outcome]
        def submit(request:)
          DocdelMailer.docdel_email(request: request).deliver_now
          Outcome.new request: request
        rescue StandardError => e
          Outcome.new request: request, errors: [e.message]
        end

        # Validate that the request has the required parameters set
        # @param request [Fulfillment::Request]
        # @return [Array<String (frozen)>]
        def validate(request:)
          scope = %i[fulfillment validation]
          errors = []
          errors << I18n.t(:no_mms_id, scope: scope) unless request.params.mms_id
          errors << I18n.t(:no_holding_id, scope: scope) unless request.params.holding_id
          errors << I18n.t(:no_user_id, scope: scope) if request.patron&.uid.blank?
          errors << I18n.t(:no_proxy_requests, scope: scope) if request.proxied?
          errors
        end
      end
    end
  end
end
