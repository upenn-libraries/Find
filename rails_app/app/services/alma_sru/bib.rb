# frozen_string_literal: true

module AlmaSRU
  # TODO:
  class Bib
    # @param mms_id [String]
    # @param args [Hash] additional query params
    # @return [AlmaSRU::Response::Availability]
    def self.get_availability(mms_id:, args: {})
      response = HTTParty.get(
        Settings.alma.sru_endpoint,
        query: { version: '1.2', operation: 'searchRetrieve', recordSchema: 'marcxml',
                 maximumRecords: 1, query: "alma.mms_id=#{mms_id}" }.merge(args)
      )
      resp = Response::Availability.new(response.body)
      return resp if resp&.records&.first&.content.present?

      raise StandardError, "SRU search failed for ID: #{mms_id}"
    end
  end
end
