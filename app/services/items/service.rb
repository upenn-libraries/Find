# TODO: figure out a less stupid name

module Items
  # service for various item methods
  class Service
    ALMA_BASE_URL = 'https://api-na.hosted.exlibrisgroup.com/almaws'.freeze
    DEFAULT_REQUEST_HEADERS =
      { "Authorization": "apikey #{Rails.application.credentials.alma_api_key}",
        "Accept": 'application/json',
        "Content-Type": 'application/json' }.freeze

    def self.item_for(mms_id:, holding_id:, item_pid:)
      item_url = "#{ALMA_BASE_URL}/v1/bibs/#{mms_id}/holdings/#{holding_id}/items/#{item_pid}"
      response = Faraday.new(
        url: item_url,
        headers: DEFAULT_REQUEST_HEADERS
      ).get

      PennItem.new(JSON.parse(response.body))
    end

    def self.items_for(mms_id:, holding_id:)
      # TODO: get items, automatically returns PennItems because we override in alma.rb monkeypatch
      Alma::BibItem.find(mms_id, holding_id: holding_id)
    end

    def self.options_for(mms_id:, holding_id:, item_id:, user_id:)
      # TODO: using the PennItem, determine which options are available for the item & user
      # return some data structure that will tell the OptionComponent which options to display
      %i[office pickup ill]
    end

    private

    def faraday(url)
      Faraday.new(url: url)
    end
  end
end
