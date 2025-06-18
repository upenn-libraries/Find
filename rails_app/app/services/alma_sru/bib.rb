module AlmaSRU
  class Bib
    SRU_ENDPOINT = 'https://na03.alma.exlibrisgroup.com/view/sru/01UPENN_INST' # TODO: move to config?

    def self.get_availability(mms_id:)
      response = HTTParty.get(
        SRU_ENDPOINT,
        query: {
          version: '1.2', operation: 'searchRetrieve', recordSchema: 'marcxml',
          maximumRecords: 1, query: "alma.mms_id=#{id}"
        }.merge(args), headers:, timeout:
      )

      if response.code == 200
        SruAvailabilityResponse.new(response)
      else
        raise StandardError, response.to_s
      end
    end
  end
end
