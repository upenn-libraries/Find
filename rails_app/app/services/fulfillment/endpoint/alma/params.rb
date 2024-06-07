# frozen_string_literal: true

module Fulfillment
  class Endpoint
    class Alma
      # This class accepts a hash of parameters and provides helpers for getting at commonly
      # used values when submitting a request to Alma.
      class Params
        attr_reader :params

        def initialize(params)
          @params = params
        end

        def item_id
          params[:item_id].presence
        end

        def holding_id
          params[:holding_id].presence
        end

        def mms_id
          params[:mms_id].presence
        end

        def comment
          params[:comment].presence
        end

        def title
          params[:title].presence
        end
      end
    end
  end
end
