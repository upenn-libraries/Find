module AlmaSRU
  module Response
    class Availability

      def initialize(response_body)
        @parsed_response = Nokogiri::XML(response_body).remove_namespaces!
      end

      def records
        @records ||= @parsed_response.css('searchRetrievalResponse', 'records')
      end

      def holdings
        @holdings ||= records.map do |rec|
          metadata = rec.css 'recordData', 'record'
          mms_id = metadata.xpath("//record/controlfield[@tag='001']")&.first&.content

          next unless mms_id

          map = if metadata.xpath("datafield[@tag='AVA']").any?
                  { datafield: 'AVA', inventory_type: 'physical' }
                elsif metadata.xpath("datafield[@tag='AVE']").any?
                  { datafield: 'AVE', inventory_type: 'electronic' }
                end

          next unless map

          metadata.xpath("datafield[@tag='#{map[:datafield]}']").map do |holding|
            hash = { 'inventory_type' => map[:inventory_type] }
            Alma::INVENTORY_SUBFIELD_MAPPING[map[:datafield]].each_with_object(hash) do |(subfield, name),hash|
              value = holding.xpath("subfield[@code='#{subfield}']")&.first&.content
              next if value.blank?

              hash[name] = value
            end
            hash
          end
        end
      end
    end
  end
end
