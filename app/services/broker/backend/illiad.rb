# frozen_string_literal: true

module Broker
  class Backend
    # Illiad submission backend
    class Illiad < Backend
      def submit(request:)
        body = submission_body_from request
        request = ::Illiad::Request.submit data: body
        Outcome.new(
          # confirmation_number: request.id
        )
      end

      def submission_body_from(request)
        # TODO: do silly 'BBM ' prefixing here
        {

        }
      end
    end
  end
end