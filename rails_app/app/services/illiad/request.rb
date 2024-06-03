# frozen_string_literal: true

module Illiad
  # Represents a request in Illiad
  # provides class methods to create, find, and update requests in Illiad
  class Request
    BASE_PATH = 'transaction'
    NOTES_PATH = 'notes'
    ROUTE_PATH = 'route'
    ARTICLE = 'Article'
    LOAN = 'Loan'

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

    # @return [DateTime, nil]
    def date
      DateTime.parse(data[:TransactionDate]) if data[:TransactionDate].present?
    end

    # @return [DateTime, nil]
    def due_date
      DateTime.parse(data[:DueDate]) if data[:DueDate].present?
    end

    # @return [Boolean]
    def loan?
      request_type == LOAN
    end

    # @return [Boolean]
    def books_by_mail?
      data[:ItemInfo1] == Fulfillment::Endpoint::Illiad::BOOKS_BY_MAIL
    end

    # @return [Boolean]
    def scan?
      request_type == ARTICLE
    end
  end
end
