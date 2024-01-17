# frozen_string_literal: true

module Inventory
  # Physical holding class
  class Physical < Base
    def status
      raw_api_data['availability']
    end

    # @return [NilClass]
    def policy; end

    # @return [String]
    def description
      raw_api_data['call_number']
    end

    # @return [NilClass]
    def format; end

    # @return [String]
    def id
      raw_api_data['holding_id']
    end

    # @return [String, NilClass]
    def href
      return nil if id.blank?

      "/catalog/#{mms_id}##{id}"
    end
  end
end

