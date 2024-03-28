# frozen_string_literal: true

module Illiad
  # Represents a request in Illiad
  # provides class methods to create, find, and update requests in Illiad
  class Request
    class Error < StandardError; end
    extend Connection

    BASE_PATH = 'transaction'
    NOTES_PATH = 'notes'
    ROUTE_PATH = 'route'
    CANCELLED_BY_USER_STATUS = ''
    # These constants can probably live on the class that prepares the data we send
    # in our requests to Illiad
    BOOKS_BY_MAIL = 'Books by Mail'
    BOOKS_BY_MAIL_REGEX = /^BBM /
    ARTICLE = 'Article'
    LOAN = 'Loan'

    attr_reader :data, :item, :id, :user

    # Create a new request in Illiad, defaults to 'Article' type unless 'RequestType' parameter included in data hash
    # Wraps the POST 'Transaction' endpoint
    # @param data [Hash] Illiad transaction data
    # @param data [String] :UserName required field
    # @param data [String] :ProcessType required field
    # @return [Illiad::Request]
    def self.submit(data:)
      # we need to first prepare this data, it needs to look different for book/scan/book-by-mail request
      response = faraday.post(BASE_PATH, data)
      new(data: response.body)
    rescue Faraday::Error => e
      raise Error, error_message(e)
    end

    # Find an Illiad request
    # Wraps the GET 'Transaction' endpoint
    # @param id [Integer] Illiad transaction number
    # @return [Illiad::Request]
    def self.find(id:)
      response = faraday.get("#{BASE_PATH}/#{id}")
      new(data: response.body)
    rescue Faraday::Error => e
      raise Error, error_message(e)
    end

    # Cancel an Illiad request
    # Wraps the PUT 'Routing Transaction Request' endpoint
    # @param id [Integer] Illiad transaction number
    # @return [Hash]
    def self.cancel(id:)
      response = faraday.put("#{BASE_PATH}/#{id}#{ROUTE_PATH}", { Status: CANCELLED_BY_USER_STATUS })
      response.body
    rescue Faraday::Error => e
      raise Error, error_message(e)
    end

    # Create a note for an Illiad request
    # Wraps POST 'Transaction Note' endpoint
    # @param id [Integer] Illiad transaction number
    # @param note [String]
    # @return [Hash]
    def self.add_note(id:, note:)
      response = faraday.post("#{BASE_PATH}/#{id}#{NOTES_PATH}", { Note: note })
      response.body
    rescue Faraday::Error => e
      raise Error, error_message(e)
    end

    # @param data [Hash]
    def initialize(data:)
      @data = data.symbolize_keys
      @item = Item.new(data: @data)
      @id = @data[:TransactionNumber]
      @user = @data[:Username]
    end

    # @return [String, nil]
    def request_type
      data[:RequestType]
    end

    # @return [String, nil]
    def document_type
      data[:DocumentType]
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
      DateTime.parse(data[:DueDate]) if data[:TransactionDate].present?
    end

    # @return [Boolean]
    def loan?
      request_type == LOAN
    end

    # @return [Boolean]
    def books_by_mail?
      return loan? unless loan?

      item.title&.starts_with?(BOOKS_BY_MAIL_REGEX) && data[:ItemInfo1] == BOOKS_BY_MAIL
    end

    # @return [Boolean]
    def scan?
      request_type == ARTICLE
    end
  end
end
