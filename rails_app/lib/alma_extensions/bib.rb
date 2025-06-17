# frozen_string_literal: true

# rubocop:disable Style/RedundantSelf, Style/HashSyntax, Style/GuardClause, Metrics/MethodLength
module AlmaExtensions
  SRU_ENDPOINT = 'https://na03.alma.exlibrisgroup.com/view/sru/01UPENN_INST' # TODO: move to config?

  # Additions for the Alma::Bib class that:
  #   - expose the "Get E-Collection for a Bib" API endpoint
  module Bib
    # Exposing the "Get E-Collection for a Bib" API endpoint. This allows us to get a top-level
    # view of any e-collections associated with a Bib.
    #
    # We need this in order to grab any Inventory that is represented in Alma as an E-Collection
    # without an associated portfolio.
    #
    # API Documentation: https://developers.exlibrisgroup.com/alma/apis/docs/bibs/R0VUIC9hbG1hd3MvdjEvYmlicy97bW1zX2lkfS9lLWNvbGxlY3Rpb25z/
    #
    # @param id [String]
    # @return [Array]
    def get_ecollections(id, args = {})
      response = HTTParty.get(
        "#{self.bibs_base_path}/#{id}/e-collections",
        query: { mms_id: id }.merge(args),
        headers:,
        timeout:
      )

      if response.code == 200
        get_body_from(response)
      else
        raise StandardError, get_body_from(response)
      end
    end

    class SruAvailabilityResponse
      def initialize(response)
        @parsed_response = Nokogiri::XML(response.body).remove_namespaces!
      end

      def holdings
        @holdings ||= records.map do |rec|
          metadata = rec.css 'recordData', 'record'
          mms_id = metadata.xpath("//record/controlfield[@tag='001']")&.first&.content

          next unless mms_id

          if metadata.xpath("boolean(/record/datafield[@tag='AVA'])")
            { mms_id => {
              mms_id: mms_id,
              holding_id: '',
              library_code: '',
              location_code: '',
              call_number: '',
              availability: ''
            } }
          elsif metadata.xpath("boolean(/record/datafield[@tag='AVE'])")
            { mms_id => {
              mms_id: mms_id,
              portfolio_id: '',
              availability: ''
            } }
          end
        end
      end

      def records
        @records ||= @parsed_response.css('searchRetrievalResponse', 'records')
      end
    end

    def sru_availability(id, args = {})
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
# rubocop:enable Style/RedundantSelf, Style/HashSyntax, Style/GuardClause, Metrics/MethodLength

Alma::Bib.extend(AlmaExtensions::Bib)
