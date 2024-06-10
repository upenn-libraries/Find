# frozen_string_literal: true

module Fulfillment
  # Submits Requests to Endpoint, sending notifications on success
  # Usage: Service.new(request: YOUR_REQUEST).submit
  #        Will return a successful or failed Fulfillment::Outcome
  class Service
    attr_reader :request, :endpoint, :errors

    # @param request [Request]
    def initialize(request:)
      @request = request
      @endpoint = request.endpoint
    end

    # Submit Request using defined Endpoint class. Ensure any exception is rescued and return an Outcome in all cases.
    # @return [Fulfillment::Outcome]
    def submit
      @errors = endpoint.validate(request: request) # return early with Outcome if validation fails
      return failed_outcome if errors.any?

      outcome = endpoint.submit(request: request)
      notify outcome: outcome
      outcome
    rescue StandardError => e
      @errors << I18n.t('fulfillment.public_error_message')
      Honeybadger.notify(e)
      failed_outcome
    end

    # @param [Outcome] outcome
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
