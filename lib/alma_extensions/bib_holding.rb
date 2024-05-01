# frozen_string_literal: true

# rubocop:disable Style/HashSyntax
module AlmaExtentions
  # Additions for the Alma::Bib class that:
  #   - expose the "Get all holding data for a Bib" API endpoint
  module BibHolding
    # The Alma API gem does not support the ability to get all holdings for a bib using the mms_id and the holding_id.
    # This extentsion is a workaround for that limitation, used to fake an item when a holding has no items.
    #
    # @param mms_id [String] The MMS ID of the bib record
    # @param options [Hash] A hash of query parameters to pass to the API
    def find_all(mms_id:, options: {})
      url = "#{bibs_base_path}/#{mms_id}/holdings"
      response = HTTParty.get(url, headers:, query: options, timeout:)
      JSON.parse(response.body)
    end
  end
end
# rubocop:enable Style/HashSyntax

Alma::BibHolding.extend(AlmaExtentions::BibHolding)
