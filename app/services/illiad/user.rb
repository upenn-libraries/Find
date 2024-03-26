# frozen_string_literal: true

module Illiad
  # Finds and represents an Illiad User
  class User
    class Error < StandardError; end
    extend Connection

    BASE_PATH = '/Users'
    USER_REQUESTS_BASE_PATH = '/UserRequests'

    attr_reader :data, :id

    # @param id [String] Illiad user id
    # @return [Illiad::User]
    def self.find(id:)
      response = faraday.get("#{BASE_PATH}/#{id}", options)
      rescue_errors(custom_error: Error)
      new(data: response.body)
    end

    # @param data [Hash] user data
    # @param data [String] 'UserName' the only required field
    # @return [Illiad::User]
    def self.create(data:)
      response = faraday.post(BASE_PATH, data)
      rescue_errors(custom_error: Error)
      new(data: response.body)
    end

    # @param data [Hash] User data from Illiad Api response
    def initialize(data:)
      @data = data.symbolize_keys
      @id = data[:UserName]
    end

    # Get all of a user's requests
    # @param options [Hash] request options
    # @param [String] :filter filter expression
    # @param [String] :order_by sort the results
    # @param [String] :top the maximum number of records to return
    # @param [String] :skip the number of results to skip before retrieving records
    # @return [Illiad::RequestSet]
    def requests(**options)
      @requests ||= begin
        response = faraday.get("#{USER_REQUESTS_BASE_PATH}/#{id}", options)
        rescue_errors(custom_error: Error)
        Illiad::RequestSet.new(requests: response.body)
      end
    end
  end
end
