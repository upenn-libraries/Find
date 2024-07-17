# frozen_string_literal: true

module Inventory
  # Make additional Holding info available that is only available by requesting a specific holding from the Alma API
  class Holding
    attr_reader :bib_holding

    # delegate to alma bib holding
    delegate_missing_to :@bib_holding

    # Get a single Holding for a given mms_id, holding_id
    # @param mms_id [String] the Alma mms_id
    # @param holding_id [String] the Alma holding_id
    # @return [Inventory::Holding]
    def self.find(mms_id:, holding_id:)
      raise ArgumentError, 'Insufficient identifiers set' unless mms_id && holding_id

      holding = Alma::BibHolding.find(mms_id: mms_id, holding_id: holding_id)
      new(holding)
    end

    # @param [Alma::BibHolding] bib_holding
    def initialize(bib_holding)
      @bib_holding = bib_holding
    end

    # @return [String]
    def id
      bib_holding['holding_id']
    end

    # Returns the "public note" values from MARC 852 subfield z
    # @return [Array, nil]
    def notes
      return if marc.blank?

      marc&.fields('852')&.filter_map { |field| field['z'] }
    end

    # @return [MARC::Record, nil]
    def marc
      @marc ||= MARC::XMLReader.new(StringIO.new(@bib_holding['anies'].first)).first
    end
  end
end
