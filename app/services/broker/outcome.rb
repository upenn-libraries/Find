# frozen_string_literal: true

module Broker
  # Response object for submission outcomes via any backend
  class Outcome
    attr_reader :request, :confirmation_number, :errors, :description

    delegate :description, to: :request

    def initialize(request:, confirmation_number: nil, errors: [])
      @request = request
      if errors.any?
        @state = :failed
        @errors = errors
      else
        @state = :success
        @confirmation_number = confirmation_number
      end
    end

    # @return [TrueClass, FalseClass]
    def success?
      @state == :success
    end

    # @return [TrueClass, FalseClass]
    def failed?
      @state == :failed
    end
  end
end
