# frozen_string_literal: true

module Illiad
  # Represents a request in Illiad
  # provides class methods to create, find, and update requests in Illiad
  class Request
    BASE_PATH = 'transaction'
    NOTES_PATH = 'notes'
    ROUTE_PATH = 'route'

    attr_reader :data

    # Find an Illiad request
    # Wraps the GET 'Transaction' endpoint
    # @param id [Integer] Illiad transaction number
    # @return [Illiad::Request]
    def self.find(id:)
      response = Client.get("#{BASE_PATH}/#{id}")
      new(**response.body)
    end

    # Create a new request in Illiad. Requires UserName and ProcessType fields. Illiad Api sets RequestType to 'Article'
    # if data does not include 'RequestType' field.
    # Wraps the POST 'Transaction' endpoint
    # @param data [Hash] Illiad transaction data
    # @return [Illiad::Request]
    def self.submit(data:)
      # we need to first prepare this data, it needs to look different for book/scan/book-by-mail request
      response = Client.post(BASE_PATH, data)
      new(**response.body)
    end

    # Create a note for an Illiad request
    # Wraps POST 'Transaction Note' endpoint
    # @param id [Integer] Illiad transaction number
    # @param note [String]
    # @return [Hash]
    def self.add_note(id:, note:)
      response = Client.post("#{BASE_PATH}/#{id}/#{NOTES_PATH}", { Note: note })
      response.body
    end

    # Route a transaction to a specific status
    # Wraps PUT 'Route Transaction' endpoint
    # @param id [Integer] Illiad transaction number
    # @param status [String]
    # @return [Illiad::Request]
    def self.route(id:, status:)
      response = Client.put("#{BASE_PATH}/#{id}/#{ROUTE_PATH}", { Status: status })
      new(**response.body)
    end

    # Update the history of a transaction
    # Wraps POST 'Transaction History' endpoint
    # @param id [Integer] Illiad transaction number
    # @param entry [String]
    # @return [Illiad::Request]
    def self.history(id:, entry:)
      response = Client.post("#{BASE_PATH}/#{id}/histories", { Entry: entry })
      new(**response.body)
    end

    # @param data [Hash]
    def initialize(**data)
      @data = data.symbolize_keys
    end

    # @return [Integer, nil]
    def id
      data[:TransactionNumber]
    end

    # @return [String, nil]
    def user
      data[:Username]
    end

    # @return [String, nil]
    def request_type
      data[:RequestType]
    end

    # @return [String, nil]
    def status
      data[:TransactionStatus]
    end

    # @return [Time, nil]
    def date
      Time.zone.parse(data[:TransactionDate]) if data[:TransactionDate].present?
    end

    # @return [Time, nil]
    def due_date
      Time.zone.parse(data[:DueDate]) if data[:DueDate].present?
    end
  end
end
