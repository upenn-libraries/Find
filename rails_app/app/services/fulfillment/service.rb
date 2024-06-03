# frozen_string_literal: true

module Fulfillment
  # Submits Requests to Endpoint, sending notifications on success
  # Usage: Service.new(request: YOUR_REQUEST).submit
  #        Will return a successful or failed Fulfillment::Outcome
  class Service
    attr_reader :request, :endpoint, :errors

    def initialize(request:)
      @request = request
      @endpoint = endpoint_class(request)
    end

    # @return [Fulfillment::Outcome]
    def submit
      @errors = endpoint.validate(request: request) # return early with Outcome if validation fails...
      return failed_outcome if errors.any?

      outcome = endpoint.submit(request: request) # this could return an error...rescue?
      notify
      outcome
    rescue StandardError => e
      errors << 'An internal error occurred.' # TODO: Illiad submit could raise interesting exceptions, but we may not want to display to patron
      Honeybadger.notify(e)
      failed_outcome
    end

    def notify
      # TODO: send email
    end

    private

    # @return [<Fulfillment::Endpoint>]
    def endpoint_class(request)
      case request.destination
      when :alma then Fulfillment::Endpoint::Alma
      when :illiad then Fulfillment::Endpoint::Illiad
      when :aeon then Fulfillment::Endpoint::Aeon
      else
        raise
      end
    end

    # @return [Fulfillment::Outcome]
    def failed_outcome
      Outcome.new(request: request, errors: errors)
    end
  end
end
