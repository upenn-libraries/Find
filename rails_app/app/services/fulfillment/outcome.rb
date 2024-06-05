# frozen_string_literal: true

module Fulfillment
  # Response object for submission outcomes via any endpoint
  class Outcome
    attr_reader :request, :confirmation_number, :errors, :item_desc, :fulfillment_desc

    delegate :description, to: :request

    def initialize(request:, item_desc: nil, fulfillment_desc: nil, confirmation_number: nil, errors: [])
      @request = request
      if errors.any?
        @state = :failed
        @errors = errors
      else
        @state = :success
        @item_desc = item_desc
        @fulfillment_desc = fulfillment_desc
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
  end
end
