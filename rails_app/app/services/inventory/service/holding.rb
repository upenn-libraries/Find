module Inventory
  class Service
    class Holding
      def initialize(holding)
        @proto_holding = holding
      end
      def public_note
        @marc.fields('852').filter_map { |field|
          # TODO: get subfield z values from field
        }.uniq.join(' ')
      end

      # TODO: not parsing the record properly
      def marc
        @marc ||= MARC::XMLReader.new(
          StringIO.new(@proto_holding['anies'].first),
          parser: :nokogiri, ignore_namespace: true
        )
      end
    end
  end
end
