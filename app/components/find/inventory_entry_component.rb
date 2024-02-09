# frozen_string_literal: true

module Find
  # Component that displays a records availability information.
  class InventoryEntryComponent < Blacklight::Component
    attr_accessor :holding_data

    # @param [Hash] holding_data
    def initialize(holding_data:)
      @holding_data = holding_data
    end

    # @return [String] id
    def id
      holding_data[:id]
    end

    # @return [String] status
    def status
      return 'See options' if holding_data[:status] == 'check_holdings'

      holding_data[:status]
    end

    # @return [String] description
    def description
      holding_data[:description]
    end

    # @return [String] entry_format
    def entry_format
      holding_data[:format]
    end

    # @return [String] location
    def location
      holding_data[:location]
    end

    # @return [String] type
    def type
      holding_data[:type]
    end

    # @return [String] href
    def href
      holding_data[:href]
    end
  end
end
