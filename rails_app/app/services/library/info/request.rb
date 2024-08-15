# frozen_string_literal: true

module Library
  module Info
    # Represents a request in LibInfo and provides methods to find and retrieve data from the library website's
    # Libraries API
    #
    # @see https://gitlab.library.upenn.edu/library/www-library-upenn-edu/-/wikis/Home/Libraries-API
    #   More information on the library website's Libraries API and available fields
    class Request
      attr_reader :data

      class << self
        # Fetches the information for a specific library based on library code
        #
        # @param library_code [String]
        # @return [Library::Info::Request, nil]
        def find(library_code:)
          response = Client.get(library_code.to_s)
          new(**response.body) if response.success? && response.body.any?
        rescue Faraday::Error => e
          Honeybadger.notify(e)
          nil
        end
      end

      # Converts data keys to symbols and empty string values to nil
      #
      # @param data [Hash]
      def initialize(**data)
        @data = data.symbolize_keys.compact_blank
      end

      # Library's hours for the current day
      #
      # @return [String]
      def hours
        data[:todays_hours]
      end

      # URL for library's hours calendar
      #
      # @return [String]
      def hours_url
        data[:hours_url]
      end

      # Parent library name if relevant, or street address
      #
      # @return [String]
      def address1
        data[:address1]
      end

      # Street address if first address line was parent library name
      #
      # @return [String, nil]
      def address2
        data[:address2]
      end

      # @return [String]
      def city
        data[:city]
      end

      # State abbreviation (ex: PA, rather than Pennsylvania)
      #
      # @return [String]
      def state_code
        data[:state_code]
      end

      # @return [String]
      def zip
        data[:zip]
      end

      # URL for library's Google Maps location
      #
      # @return [String]
      def maps_url
        data[:google_maps]
      end

      # @return [String]
      def email
        data[:email]
      end

      # @return [String]
      def phone
        data[:phone]
      end

      # URL for library's homepage
      #
      # @return [String]
      def library_url
        data[:url]
      end
    end
  end
end
