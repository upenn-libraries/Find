# frozen_string_literal: true

module Illiad
  # Represents a request in Illiad
  # provides class methods to submit and find requests in Illiad
  class Request
    include Connection

    BASE_PATH = '/Transaction'

    attr_reader :data, :id, :user_id

    class << self

      # Create a new request in Illiad
      # @param data [Hash] Illiad transaction data
      # @return [Illiad::Request]
      def submit(data:)
        # we need to first prepare this data, it needs to look different for book/scan/book-by-mail request
        response = faraday.post(BASE_PATH, data)

        Illiad::Request.new(data: response.body)
      end

      # Find an Illiad request
      # @param options [Hash] request options
      # @request options [Illiad::Response]
      def find(id:, **options)
        response = faraday.get("#{BASE_PATH}/#{id}", options)

        Illiad::Request.new(data: response.body)
      end
    end

    # @param data [Hash]
    def initialize(data:)
      @data = data.symbolize_keys
      @id = data[:TransactionNumber]
      @user_id = data[:UserName]
    end
  end
end

