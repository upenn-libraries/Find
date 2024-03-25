# frozen_string_literal: true

module Illiad
  # Finds and represents an Illiad User
  class User
    include Connection

    BASE_PATH = '/Users'
    USER_REQUESTS_BASE_PATH = '/UserRequests'

    attr_reader :data, :user_id

    # @param user_id [String]
    # @param options [Hash] request options
    # @return [Illiad::User]
    def self.find(user_id:, **options)
      response = faraday.get("#{BASE_PATH}/#{user_id}", options)

      new(data: response.body)
    end

    def self.create; end

    # @param data [Hash] User data from Illiad Api response
    def initialize(data:)
      @data = data.symbolize_keys
      @user_id = data[:UserName]
    end

    # @param options [Hash] request options
    # @return [Illiad::RequestSet]
    def requests(**options)
      response = faraday.get("#{USER_REQUESTS_BASE_PATH}/#{user_id}", options)

      @requests ||= Illiad::RequestSet.new(requests: response.body)
    end
  end
end
