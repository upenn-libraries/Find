# frozen_string_literal: true

module Fulfillment
  class Endpoint
    # Alma submission endpoint
    class Alma < Endpoint
      class << self
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

        # @todo I18n-ize these messages
        # @param [Fulfillment::Request] request
        # @return [Array<String (frozen)>]
        def validate(request:)
          errors = []
          errors << 'No pickup location provided' if request.pickup_location.blank?
          errors << 'No record identifier provided' if request.params.mms_id.blank?
          errors << 'No holding identifier provided' if request.params.holding_id.blank?
          errors << 'No user identifier provided' if request.user&.uid.blank?
          errors
        end

        private

        # @param [Request] request
        # @return [Hash{Symbol->String (frozen)}]
        def submission_params(request:)
          { user_id: request.user.uid,
            request_type: 'HOLD',
            comment: request.params.comment,
            mms_id: request.params.mms_id,
            holding_id: request.params.holding_id,
            pickup_location_type: 'LIBRARY',
            pickup_location_library: request.pickup_location }
        end
      end
    end
  end
end
