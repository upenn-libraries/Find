# frozen_string_literal: true

module Broker
  class Backend
    # Alma submission backend
    class Alma < Backend
      def submit(request:)
        params = { body: submission_body_from(request),
                   mms_id: request.mms_id,
                   holding_id: request.holding_id,
                   user_id: request.user.id }
        # determine if item or title request
        response = if request.item_id
                     ::Alma::ItemRequest.submit(params.merge({item_pid: request.item_id}))
                   else
                     ::Alma::BibRequest.submit(params)
                   end
        confirmation_number = response[:confirmation_number] # TODO: validate how to get this
        Outcome.new(request: request, confirmation_number: confirmation_number)
      end

      def submission_body_from(request)
        { request_type: 'HOLD',
          user_id: request.user.id, # TODO: is this the right way to the user id?
          user_id_type: 'all_unique',
          pickup_location_type: 'LIBRARY',
          pickup_location_library: request.pickup_location, # TODO: where in request?
          comment: request.comment } # TODO: where in request?
      end
    end
  end
end
