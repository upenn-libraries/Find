# frozen_string_literal: true

module Broker
  class Backend
    # Alma submission backend
    class Alma < Backend
      def submit(request:)
        body = submission_body_from request
        # determine if item or title request
        response = if item_data?
                     Alma::ItemRequest.submit({})
                   else
                     Alma::BibRequest.submit({})
                   end
        Outcome.new(
          # confirmation_number: request.id
        )
      end

      def submission_body_from(request)
        {}
      end
    end
  end
end