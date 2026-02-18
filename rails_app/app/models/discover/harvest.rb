# frozen_string_literal: true

module Discover
  # Represents a harvest of an external resource
  class Harvest < ApplicationRecord
    validates :source, presence: true, uniqueness: true

    self.table_name = 'discover_harvests'

    # @return [Hash]
    def headers
      {
        'If-None-Match': etag,
        'If-Modified-Since': resource_last_modified_httpdate
      }
    end

    # @return [Discover::Harvest]
    def update_from_response_headers!(response_headers)
      update!(resource_last_modified: response_headers['last-modified'], etag: response_headers['etag'])
    end

    private

    # @return [String]
    def resource_last_modified_httpdate
      return unless resource_last_modified

      resource_last_modified.httpdate
    end
  end
end
