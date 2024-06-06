# frozen_string_literal: true

module Fulfillment
  class Endpoint
    class Alma
      # TODO: zzz
      class Params
        attr_reader :open_params

        # TODO: we should memoize all of these methods

        def initialize(open_params)
          @open_params = open_params
        end

        def item_id

        end

        def holding_id

        end

        def title
          params[:title]
        end
      end
    end
  end
end
