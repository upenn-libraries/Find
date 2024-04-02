# frozen_string_literal: true

module Illiad
  # Finds and represents an Illiad User
  class User
    class Error < StandardError; end

    BASE_PATH = 'users'
    USER_REQUESTS_BASE_PATH = 'Transaction/UserRequests'

    attr_reader :data, :id

    # @param id [String] Illiad user id
    # @return [Illiad::User]
    def self.find(id:)
      response = Connection.create.get("#{BASE_PATH}/#{id}")
      new(**response.body)
    rescue Faraday::Error => e
      raise Error, Connection.error_messages(error: e)
    end

    # Illiad API documentation states that _only_ UserName is required. User
    # create requests fail, though, with an empty 400 response if NVTGC field is not also specified.
    # @param data [Hash] user data
    # @param data [String] 'UserName' required field
    # @return [Illiad::User]
    def self.create(data:)
      response = Connection.create.post(BASE_PATH, data)
      new(**response.body)
    rescue Faraday::Error => e
      raise Error, Connection.error_messages(error: e)
    end

    # @note the api does not support updating a user
    def self.update
      raise Error, 'Api does not support updating a user.'
    end

    # Get all of a user's requests
    # @param options [Hash] request options
    # @param [String] :filter filter expression
    # @param [String] :order_by sort the results
    # @param [String] :top the maximum number of records to return
    # @param [String] :skip the number of results to skip before retrieving records
    # @return [Illiad::RequestSet]
    def self.requests(user_id:, **options)
      response = Connection.create.get("#{USER_REQUESTS_BASE_PATH}/#{user_id}", options)
      Illiad::RequestSet.new(requests: response.body)
    rescue Faraday::Error => e
      raise Error, Connection.error_messages(error: e)
    end

    # @param data [Hash] User data from Illiad Api response
    def initialize(**data)
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
