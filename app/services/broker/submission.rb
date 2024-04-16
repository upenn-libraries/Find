# frozen_string_literal: true

module Broker
  # Submits Requests to Backend
  class Service
    class << self
      def validate(backend, request)
        # TODO: ?
      end

      def submit(request)
        backend = request.destination.constantize # instantiate backend class
        validate(backend, request)
        outcome = backend.submit(request) # call backend submit class method
        notify(request, outcome) # send confirmation email with tracking number
        # return identifier to allow caller to route to a show page
      end
    end
  end
end
