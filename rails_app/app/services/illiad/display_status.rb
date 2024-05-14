# frozen_string_literal: true

module Illiad
  # Represents a DisplayStatus Illiad
  # provides class methods to find all display status rules in Illiad
  class DisplayStatus
    BASE_PATH = 'DisplayStatus'

    def self.find_all
      response = Client.get(BASE_PATH)
      response.body.map do |display_status_data|
        new(**display_status_data)
      end
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
