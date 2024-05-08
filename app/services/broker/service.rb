# frozen_string_literal: true

module Broker
  # Submits Requests to Backend, sending notifications on success
  # Usage: Service.new(request: YOUR_REQUEST).submit
  #        Will return a successful or failed Broker::Outcome
  class Service
    attr_reader :request, :backend, :errors

    def initialize(request:)
      @request = request
      @backend = backend_class(request)
    end

    # @return [Broker::Outcome]
    def submit
      @errors = backend.validate(request: request) # return early with Outcome if validation fails...
      return failed_outcome if errors.any?

      outcome = backend.submit(request: request)
      notify
      outcome
    end

    def notify
      # TODO: send email
    end

    private

    # @return [Broker::Backend]
    def backend_class(request)
      case request.destination
      when :alma then Broker::Backend::Alma
      when :illiad then Broker::Backend::Illiad
      when :aeon then Broker::Backend::Aeon
      else
        raise
      end
    end

    # @return [Broker::Outcome]
    def failed_outcome
      Outcome.new(request: request, errors: errors)
    end
  end
end
