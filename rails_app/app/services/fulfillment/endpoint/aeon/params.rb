# frozen_string_literal: true

module Fulfillment
  class Endpoint
    class Aeon
      # TODO: maybe remove for now
      class Params
        attr_reader :open_params

        # TODO: we should memoize all of these methods

        def initialize(open_params)
          @open_params = open_params
        end
      end
    end
  end
end
