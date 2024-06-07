# frozen_string_literal: true

module Fulfillment
  # Submits Requests to Endpoint, sending notifications on success
  # Usage: Service.new(request: YOUR_REQUEST).submit
  #        Will return a successful or failed Fulfillment::Outcome
  class Service
    attr_reader :request, :endpoint, :errors

    def initialize(request:)
      @request = request
      @endpoint = request.endpoint
    end

    # @return [Fulfillment::Outcome]
    def submit
      @errors = endpoint.validate(request: request) # return early with Outcome if validation fails
      return failed_outcome if errors.any?

      outcome = endpoint.submit(request: request)
      notify outcome: outcome
      outcome
    rescue StandardError => e
      @errors << 'An internal error occurred.'
      Honeybadger.notify(e)
      failed_outcome
    end

    def notify(outcome:)
      # TODO: send email using outcome (item_desc, fulfillment_desc)
    end

    private

    # @return [Fulfillment::Outcome]
    def failed_outcome
      Outcome.new(request: request, errors: errors)
    end
  end
end
