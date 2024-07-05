# frozen_string_literal: true

module Inventory
  class Service
    # Make additional Holding info available
    class Holding
      # @param [Alma::BibHolding] holding
      def initialize(holding)
        @holding_data = holding
      end

      # Returns the "public note" values from MARC 852 subfield z
      # @return [String]
      def public_note
        return if marc.blank?

        marc.fields('852').filter_map { |field| field['z'] }.uniq.join(' ')
      end

      # @return [MARC::Record, nil]
      def marc
        @marc ||= MARC::XMLReader.new(StringIO.new(@holding_data['anies'].first)).first
      end
    end
  end
end
