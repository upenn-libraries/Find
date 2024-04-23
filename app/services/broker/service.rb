# frozen_string_literal: true

module Broker
  # Submits Requests to Backend
  class Service
    class << self

      # @return [Broker::Outcome]
      def submit(request)
        backend = backend_class(request) # instantiate backend class
        backend.validate(request: request) # raise?
        outcome = backend.submit(request: request) # call backend submit class method
        notify(request, outcome) # send confirmation email with tracking number
        outcome
      end

      # @return [Broker::Backend]
      def backend_class(request)
        case request.destination
        when :alma then Broker::Alma
        when :illiad then Broker::Illiad
        when :aeon then Broker::Aeon
        else
          raise
        end
      end

      # @param request [Broker::Request]
      # @param outcome [Broker::Outcome]
      def notify(request, outcome)
        # TODO: send email to request.user
      end
    end
  end
end
