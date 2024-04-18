# TODO: figure out a less stupid name

module Items
  # service for various item methods
  class Service
    ALMA_BASE_URL = 'https://api-na.hosted.exlibrisgroup.com/almaws'.freeze

    FACULTY_EXPRESS_CODE = 'FacEXP'.freeze
    COURTESY_BORROWER_CODE = 'courtesy'.freeze
    STUDENT_GROUP_CODES = %w[undergrad graduate GIC].freeze

    DEFAULT_REQUEST_HEADERS =
      { "Authorization": "apikey #{Rails.application.credentials.alma_api_key}",
        "Accept": 'application/json',
        "Content-Type": 'application/json' }.freeze

    # @return [PennItem]
    def self.item_for(mms_id:, holding_id:, item_pid:)
      raise ArgumentError, 'Insufficient identifiers set' unless mms_id && holding_id && item_pid

      item_url = "#{ALMA_BASE_URL}/v1/bibs/#{mms_id}/holdings/#{holding_id}/items/#{item_pid}"
      response = Faraday.new(
        url: item_url,
        headers: DEFAULT_REQUEST_HEADERS
      ).get

      PennItem.new(JSON.parse(response.body))
    end

    # @return [BibItemSet]
    def self.items_for(mms_id:, holding_id:)
      raise ArgumentError, 'Insufficient identifiers set' unless mms_id && holding_id

      Alma::BibItem.find(mms_id, holding_id: holding_id)
    end

    # @return [Array]
    def self.options_for(item:, ils_group:)
      options = []
      if item.checkoutable?
        options << :pickup
        options << :office if ils_group == FACULTY_EXPRESS_CODE
        options << :mail unless ils_group == COURTESY_BORROWER_CODE
        options << :scan if item.scannable?
      elsif item.aeon_requestable?
        options << :aeon
      elsif item.at_archives?
        options << :archives
      end
      options
    end
  end
end
