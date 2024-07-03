# frozen_string_literal: true

module Fulfillment
  class Endpoint
    class Alma
      # This class accepts a hash of parameters and provides helpers for getting at commonly
      # used values when submitting a request to Alma.
      class Params
        attr_reader :params

        # @param params [Hash]
        def initialize(params)
          @params = params
        end

        # @return [String, nil]
        def item_id
          params[:item_id].presence
        end

        # @return [String, nil]
        def holding_id
          params[:holding_id].presence
        end

        # @return [String, nil]
        def mms_id
          params[:mms_id].presence
        end

        # @return [String, nil]
        def comments
          params[:comments].presence
        end

        # @return [String, nil]
        def title
          params[:title].presence
        end

        # @return [String, nil]
        def author
          params[:author].presence
        end
      end
    end
  end
end
