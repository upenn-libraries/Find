# frozen_string_literal: true

require 'csv'

module Discover
  module Parser
    # Abstract class that all Discover parser classes inherit from.
    class Base
      class << self
        # Import data from source.
        #
        # @param file [String] the input file path or content
        # @return [nil]
        def import(file:)
          return unless file

          parse_tabular_data(file)
        end

        def delete_missing(file:)
          return unless file

          delete_absent_records(file)
        end

        private

        # Delete existing records not included in present harvest.
        # Must be implemented by subclasses.
        #
        # @param file [String] the input file path or content
        # @return [nil]
        def delete_absent_records(file)
          raise NotImplementedError
        end

        # Parse given tabular data into records.
        # Must be implemented by subclasses.
        #
        # @param file [String] the input file path or content
        # @return [nil]
        def parse_tabular_data(file)
          raise NotImplementedError
        end

        # Sanitize string with HTML tags
        #
        # @param description [String]
        # @return [String, nil]
        def sanitize(description)
          ActionView::Base.full_sanitizer.sanitize(description)&.gsub(/[Ââ]/, '')&.gsub('&nbsp;', ' ')
        end
      end
    end
  end
end
