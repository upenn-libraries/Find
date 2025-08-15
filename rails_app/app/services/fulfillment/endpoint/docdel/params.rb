# frozen_string_literal: true

module Fulfillment
  class Endpoint
    class Docdel
      # This class accepts a hash of parameters and provides helpers for getting at commonly
      # used values when sending request to Lippincott Document Delivery service.
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

        # @return [String, nil]
        def year
          params[:year].presence
        end

        # @return [String, nil]
        def edition
          params[:edition].presence
        end

        # @return [String, nil]
        def publisher
          params[:publisher].presence
        end

        # @return [String, nil]
        def place
          params[:place].presence
        end

        # @return [String, nil]
        def isbn
          params[:isbn].presence
        end

        # @return [String, nil]
        def article
          params[:article].presence
        end

        # @return [String, nil]
        def journal
          params[:journal].presence
        end

        # @return [String, nil]
        def volume
          params[:volume].presence || item.volume
        end

        # @return [String, nil]
        def issue
          params[:issue].presence || item.issue
        end

        # @return [String, nil]
        def pages
          params[:pages].presence
        end

        # @return [String, nil]
        def source
          params[:source].presence
        end

        private

        # @return [Inventory::Item]
        def item
          @item ||= Inventory::Item.find mms_id: mms_id, holding_id: holding_id, item_id: item_id
        end
      end
    end
  end
end
