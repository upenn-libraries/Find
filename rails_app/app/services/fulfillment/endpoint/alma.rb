# frozen_string_literal: true

module Fulfillment
  class Endpoint
    # Alma submission endpoint
    class Alma < Endpoint
      class << self
        # Submit a Request to the Alma endpoint using either the BibRequest or ItemRequest API endpoints
        # @param request [Request]
        # @return [Outcome]
        def submit(request:)
          params = submission_params(request: request)
          response = if request.params.item_id
                       ::Alma::ItemRequest.submit(params.merge({ item_pid: request.params.item_id }))
                     else
                       ::Alma::BibRequest.submit(params)
                     end
          Outcome.new(
            request: request, confirmation_number: "ALMA_#{response.raw_response['request_id']}"
          )
        end

        # Validate that the request has the required parameters set
        # @param request [Fulfillment::Request]
        # @return [Array<String (frozen)>]
        def validate(request:)
          scope = %i[fulfillment validation]
          errors = []
          errors << I18n.t(:no_pickup_location, scope: scope) unless request.pickup_location
          errors << I18n.t(:no_mms_id, scope: scope) unless request.params.mms_id
          errors << I18n.t(:no_holding_id, scope: scope) unless request.params.holding_id
          errors << I18n.t(:no_user_id, scope: scope) if request.patron&.uid.blank?
          errors << I18n.t(:no_proxy_requests, scope: scope) if request.proxied?
          errors
        end

        private

        # @param request [Request]
        # @return [Hash{Symbol->String (frozen)}]
        def submission_params(request:)
          { user_id: request.patron.uid,
            request_type: 'HOLD',
            comments: request.params.comments,
            mms_id: request.params.mms_id,
            holding_id: request.params.holding_id,
            pickup_location_type: 'LIBRARY',
            pickup_location_library: request.pickup_location }
        end
      end
    end
  end
end
