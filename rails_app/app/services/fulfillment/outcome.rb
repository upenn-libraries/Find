# frozen_string_literal: true

module Fulfillment
  # Response object for submission outcomes via any endpoint
  class Outcome
    attr_reader :request, :confirmation_number, :errors, :item_desc, :fulfillment_desc

    delegate :description, to: :request

    # @param request [Request] request as submitted
    # @param confirmation_number [String, nil] confirmation number if request was successful
    # @param errors [Array] error messages if the submission encountered problems
    def initialize(request:, confirmation_number: nil, errors: [])
      @request = request
      if errors.any?
        @state = :failed
        @errors = errors
      else
        @state = :success
        @item_desc = [request.params.title, request.params.author].compact.join(' - ')
        @fulfillment_desc = fulfillment_description
        @confirmation_number = confirmation_number
      end
    end

    # @return [String (frozen), nil]
    def error_message
      @errors&.to_sentence
    end

    # @return [Boolean]
    def success?
      @state == :success
    end

    # @return [Boolean]
    def failed?
      @state == :failed
    end

    private

    def fulfillment_description
      case request.delivery
      when Request::Options::PICKUP
        I18n.t('fulfillment.outcome.email.pickup', pickup_location: human_readable_pickup_location)
      else
        I18n.t(request.delivery, scope: 'fulfillment.outcome.email')
      end
    end

    def human_readable_pickup_location
      Settings.locations.pickup.to_h.find { |_k, v| v[:ils] == request.pickup_location }
              &.first.to_s || request.pickup_location
    end
  end
end
