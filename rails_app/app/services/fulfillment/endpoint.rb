# frozen_string_literal: true

module Fulfillment
  # Base Broker Backend
  class Endpoint
    class << self
      # @param request [Broker::Request]
      # @return [Array]
      def validate(request:)
        raise NotImplementedError
      end

      def submit(request:)
        raise NotImplementedError
      end
    end
  end
end
