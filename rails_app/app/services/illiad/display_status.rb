# frozen_string_literal: true

module Illiad
  # Represents a DisplayStatus Illiad
  # provides class methods to find all display status rules in Illiad
  class DisplayStatus
    BASE_PATH = 'DisplayStatus'

    def self.find_all
      response = Client.get(BASE_PATH)
      Illiad::DisplayStatusSet.new(display_statuses: response.body)
    end

    def initialize(data)
      @data = data.symbolize_keys
    end

    def transaction_status
      @data[:TransactionStatus]
    end

    def display_status
      @data[:DisplayStatus]
    end
  end
end
