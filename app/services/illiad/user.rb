# frozen_string_literal: true

module Illiad
  # Finds and represents an Illiad User
  class User
    class Error < StandardError; end
    extend Connection

    BASE_PATH = 'users'
    USER_REQUESTS_BASE_PATH = 'Transaction/UserRequests'

    attr_reader :data, :id

    # @param id [String] Illiad user id
    # @return [Illiad::User]
    def self.find(id:)
      response = faraday.get("#{BASE_PATH}/#{id}")
      new(data: response.body)
    rescue Faraday::Error => e
      raise Error, error_message(e)
    end

    # @param data [Hash] user data
    # @param data [String] 'UserName' the only required field
    # @return [Illiad::User]
    def self.create(data:)
      response = faraday.post(BASE_PATH, data)
      new(data: response.body)
    rescue Faraday::Error => e
      raise Error, error_message(e)
    end

    # Get all of a user's requests
    # @param options [Hash] request options
    # @param [String] :filter filter expression
    # @param [String] :order_by sort the results
    # @param [String] :top the maximum number of records to return
    # @param [String] :skip the number of results to skip before retrieving records
    # @return [Illiad::RequestSet]
    def self.requests(user_id:, **options)
      response = faraday.get("#{USER_REQUESTS_BASE_PATH}/#{user_id}", options)
      Illiad::RequestSet.new(requests: response.body)
    rescue Faraday::Error => e
      raise Error, error_message(e)
    end

    # @param data [Hash] User data from Illiad Api response
    def initialize(data:)
      @data = data.symbolize_keys
      @id = @data[:UserName]
    end

    # Get all of the user's requests
    # @param options [Hash] request options
    # @param [String] :filter filter expression
    # @param [String] :order_by sort the results
    # @param [String] :top the maximum number of records to return
    # @param [String] :skip the number of results to skip before retrieving records
    # @return [Illiad::RequestSet]
    def requests(**options)
      @requests ||= self.class.requests(user_id: id, **options)
    end
  end
end
