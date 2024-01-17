# frozen_string_literal: true

module Inventory
  # Electronic holding class
  class Electronic < Base
    # Define href as URI
    # BASE_URL = URI.new
    # @return [String]
    def status
      raw_api_data['activation_status']
    end

    # @return [String]
    def policy; end

    # @return [String]
    def description
      raw_api_data['collection']
    end

    # @return [String, NilClass]
    def format; end

    # @return [String]
    def id
      raw_api_data['portfolio_pid']
    end

    # @return [String]
    def href
      return nil if id.blank?

      'https://upenn.alma.exlibrisgroup.com/view/uresolver/01UPENN_INST/openurl?Force_direct=true&portfolio_pid=' \
        "#{id}&rfr_id=info%3Asid%2Fprimo.exlibrisgroup.com&u.ignore_date_coverage=true"
    end
  end
end
