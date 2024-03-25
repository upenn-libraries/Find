# frozen_string_literal: true

module Illiad
  # Represents a request in Illiad
  # provides class methods to submit and find requests in Illiad
  class Request
    include Connection

    BASE_PATH = '/Transaction'
    NOTES_PATH = '/notes'
    # These constants can probably live on the class that prepares yhe data we send
    # in our requests to Illiad
    BOOKS_BY_MAIL = 'Books by Mail'
    BOOKS_BY_MAIL_REGEX = /^BBM /
    ARTICLE = 'Article'
    LOAN = 'Loan'

    attr_reader :data, :item_data, :id, :user

    # Create a new request in Illiad
    # @param data [Hash] Illiad transaction data
    # @return [Illiad::Request]
    def self.submit(data:)
      # we need to first prepare this data, it needs to look different for book/scan/book-by-mail request
      response = faraday.post(BASE_PATH, data)

      new(data: response.body)
    end

    # Create a note for a request
    # @param id [Integer] Illiad transaction number
    # @param note [String]
    # @return [Hash]
    def self.add_note(id:, note:)
      response = faraday.post("#{BASE_PATH}/#{id}/#{NOTES_PATH}", { Note: note })

      response.body
    end

    # Find an Illiad request
    # @param id [Integer] Illiad transaction number
    # @param options [Hash] request options
    # @return [Illiad::Response]
    def self.find(id:, **options)
      response = faraday.get("#{BASE_PATH}/#{id}", options)

      new(data: response.body)
    end

    # @param data [Hash]
    def initialize(data:)
      @data = data.symbolize_keys
      @item_data = ItemData.new(@data)
      @id = data[:TransactionNumber]
      @user = data[:UserName]
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
      DateTime.new(data[:TransactionDate])
    end

    # @return [String, nil]
    def due_date
      data[:DueDate]
    end

    # @return [Boolean]
    def loan?
      request_type == LOAN
    end

    # @return [Boolean]
    def books_by_mail?
      return loan? unless loan?

      item_data.title.start_with?(BOOKS_BY_MAIL_REGEX) && data[:ItemInfo1] == BOOKS_BY_MAIL
    end

    # @return [Boolean]
    def scan?
      request_type == ARTICLE
    end
  end
end
