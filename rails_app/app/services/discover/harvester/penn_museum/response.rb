# frozen_string_literal: true

module Discover
  module Harvester
    class PennMuseum
      # Simple object to package the museum response data during harvesting
      class Response
        NOT_MODIFIED_STATUS = 304

        # @param code [Integer]
        # @return [Boolean]
        def self.not_modified?(code)
          code == NOT_MODIFIED_STATUS
        end

        # @param response [Faraday::Response]
        def initialize(response:)
          @response = response
        end

        delegate :success?, to: :@response

        # @return [String]
        def last_modified
          @response.headers['last-modified']
        end

        # @return [String]
        def etag
          @response.headers['etag']
        end

        # @return [Hash]
        def headers
          { 'last-modified' => last_modified, 'etag' => etag }
        end
      end
    end
  end
end
