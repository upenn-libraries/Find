# frozen_string_literal: true

module Inventory
  # Make additional Holding info available
  class Holding
    # Get a single Holding for a given mms_id, holding_id
    # @param mms_id [String] the Alma mms_id
    # @param holding_id [String] the Alma holding_id
    def self.find(mms_id:, holding_id:)
      raise ArgumentError, 'Insufficient identifiers set' unless mms_id && holding_id

      holding = Alma::BibHolding.find(mms_id: mms_id, holding_id: holding_id)
      new(holding)
    end

    # @param [Alma::BibHolding] bib_holding
    def initialize(bib_holding)
      @bib_holding = bib_holding.holding
    end

    # Returns the "public note" values from MARC 852 subfield z
    # @return [String]
    def public_note
      return if marc.blank?

      marc&.fields('852')&.filter_map { |field| field['z'] }.uniq.join(' ')
    end

    # @return [MARC::Record, nil]
    def marc
      @marc ||= MARC::XMLReader.new(StringIO.new(@bib_holding['anies'].first)).first
    end
  end
end
