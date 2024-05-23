# frozen_string_literal: true

module Fulfillment
  class Endpoint
    # Alma submission endpoint
    class Alma < Endpoint
      class << self
        def submit(request:)
          params = { user_id: request.user.uid, request_type: 'HOLD',
                     comment: request.item_parameters[:comment],
                     mms_id: request.item_parameters[:mms_id], holding_id: request.item_parameters[:holding_id],
                     pickup_location_type: 'LIBRARY', pickup_location_library: request.fulfillment_options[:pickup_location] }
          response = if request.item_parameters[:item_pid].present?
                       ::Alma::ItemRequest.submit(params.merge({ item_pid: request.item_parameters[:item_pid] }))
                     else
                       ::Alma::BibRequest.submit(params)
                     end
          confirmation_number = "ALMA_#{response.raw_response['request_id']}"
          Outcome.new(request: request, confirmation_number: confirmation_number)
        end

        # @todo I18n-ize these messages
        # @param [Fulfillment::Request] request
        # @return [Array<String (frozen)>]
        def validate(request:)
          errors = []
          errors << 'No pickup location provided' if request.fulfillment_options[:pickup_location].blank?
          errors << 'No record identifier provided' if request.item_parameters[:mms_id].blank?
          errors << 'No holding identifier provided' if request.item_parameters[:holding_id].blank?
          errors << 'No user identifier provided' if request.user&.uid.blank?
          errors
        end
      end
    end
  end
end
