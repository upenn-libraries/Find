# frozen_string_literal: true

module Find
  # Component that displays a records availability information.
  class InventoryEntryComponent < Blacklight::Component
    # @param [Hash] holding_data
    def initialize(holding_data:)
      @holding_data = holding_data
      @id = holding_data[:id]
      @status = holding_data[:status]
      @status = 'See options' if holding_data[:status] == 'check_holdings'
      @description = holding_data[:description]
      @format = holding_data[:format]
      @location = holding_data[:location]
      @type = holding_data[:type]
      @href = holding_data[:href]
    end
  end
end
