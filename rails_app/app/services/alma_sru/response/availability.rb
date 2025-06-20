# frozen_string_literal: true

module AlmaSRU
  module Response
    # Represent an SRU response for a Bib availability call. Intended to serve as a drop-in replacement for the Alma gem
    # `Alma::AvailabilityResponse` object.
    class Availability
      attr_reader :parsed_response

      # @param response_body [String]
      def initialize(response_body)
        @parsed_response = Nokogiri::XML(response_body).remove_namespaces!
      end

      # Was the search request successful but returned 0 results?
      # @return [Boolean]
      def empty?
        parsed_response.xpath('//numberOfRecords')&.first&.content == '0'
      end

      # Did the search request fail for some documented reason (e.g., bad query syntax)?
      # @return [Boolean, nil]
      def failed?
        parsed_response.xpath('//diagnostics')&.first&.present?
      end

      # Parse out top level "records" from SRU response, but there will only be one
      # @return [Nokogiri::XML::Element]
      def records
        @records ||= parsed_response.xpath('//searchRetrieveResponse/records').first
      end

      # @return [Array]
      def holdings
        record = records.xpath('//recordData/record').first
        map = if record.xpath("datafield[@tag='AVA']").any?
                { datafield: 'AVA', inventory_type: 'physical' }
              elsif record.xpath("datafield[@tag='AVE']").any?
                { datafield: 'AVE', inventory_type: 'electronic' }
              end
        return [] unless map # no inventory we care about

        map_subfields_to_hashes record: record, map: map
      end

      private

      # @param map [Hash]
      # @param record [Nokogiri::XML::Element]
      # @return [Array]
      def map_subfields_to_hashes(record:, map:)
        record.xpath("datafield[@tag='#{map[:datafield]}']").map do |holding|
          { 'inventory_type' => map[:inventory_type] }.tap do |hash|
            Alma::INVENTORY_SUBFIELD_MAPPING[map[:datafield]].each do |subfield, name|
              value = holding.xpath("subfield[@code='#{subfield}']")&.first&.content
              next if value.blank?

              hash[name] = value
            end
          end
        end
      end
    end
  end
end
