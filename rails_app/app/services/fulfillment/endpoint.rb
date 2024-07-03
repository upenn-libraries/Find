# frozen_string_literal: true

module Fulfillment
  # Base Broker Backend. Endpoint classes must implement :validate and :submit
  class Endpoint
    class << self
      # @param request [Request]
      # @return [Array]
      def validate(request:)
        raise NotImplementedError
      end

      # @param request [Request]
      # @return [Outcome]
      def submit(request:)
        raise NotImplementedError
      end
    end
  end
end
