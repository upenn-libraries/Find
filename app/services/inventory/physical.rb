# frozen_string_literal: true

module Inventory
  # Physical holding class
  class Physical < Base
    # @return [String, nil]
    def status
      raw_api_data['availability']
    end

    # @return [String, nil]
    def policy; end

    # @return [String, nil]
    def description
      raw_api_data['call_number']
    end

    # @return [String, nil]
    def format; end

    # @return [String, nil]
    def id
      raw_api_data['holding_id']
    end

    # @return [String, nil]
    def href
      return nil if id.blank?

      "/catalog/#{mms_id}##{id}"
    end
  end
end
