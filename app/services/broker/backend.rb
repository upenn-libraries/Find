# frozen_string_literal: true

module Broker
  # Base Broker Backend
  class Backend
    def validate(request:)
      raise NotImplementedError
    end

    def submit(request:)
      raise NotImplementedError
    end
  end
end
