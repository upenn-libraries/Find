# frozen_string_literal: true

module Broker
  # Submits Requests to Backend, sending notifications on success
  # Usage: Service.new(request: YOUR_REQUEST).submit
  #        Will return a successful or failed Broker::Outcome
  class Service
    attr_reader :request, :backend

    def initialize(request:)
      @request = request
      @backend = backend_class(request)
    end

    # @return [Broker::Outcome]
    def submit
      @errors = backend.validate(request) # return early with Outcome if validation fails...
      outcome = backend.submit(request) # this returns outcome, but we could build the outcome here - except that the different backend submission methods will return inconsistent objects
      notify
      outcome
    end

    def notify
      # TODO: send email
    end

    class << self

      # @return [Broker::Outcome]
      def submit(request)
        backend = backend_class(request) # instantiate backend class
        backend.validate(request: request) # raise ValidationError
        outcome = backend.submit(request: request) # call backend submit class method
        notify(request, outcome) # send confirmation email with tracking number
        outcome
      rescue Broker::ValidationError => e
        # TODO: set errors and return an Outcome
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
