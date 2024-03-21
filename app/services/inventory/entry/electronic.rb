# frozen_string_literal: true

module Inventory
  class Entry
    # Electronic holding class
    class Electronic < Inventory::Entry
      # Base host, path, and params to electronic resource (portfolio)
      HOST = Inventory::Constants::ERESOURCE_LINK_HOST
      PATH = Inventory::Constants::ERESOURCE_LINK_PATH
      PARAMS = { Force_direct: true,
                 portfolio_pid: nil,
                 rfr_id: Inventory::Constants::ERESOURCE_LINK_RFR_ID,
                 'u.ignore_date_coverage': true }.freeze

      # @return [String, nil]
      def id
        data[:portfolio_pid]
      end

      # @return [String, nil]
      def description
        data[:collection]
      end

      # @return [String, nil]
      def status
        data[:activation_status]
      end

      # No location available for electronic entries.
      def location
        nil
      end

      # No policy available for electronic entries.
      #
      # @return [nil]
      def policy
        nil
      end

      # Format is only exposed via the Inventory::ElectronicDetail object to prevent additional API calls.
      def format
        nil
      end

      # @return [String, nil]
      def coverage_statement
        data[:coverage_statement]
      end

      # @note for a collection record (e.g. 9977925541303681) Electronic Collection API returns
      #       "url_override" field that has a neat hdl.library.upenn.edu link to the electronic collection
      # @return [String, nil]
      def href
        return nil if id.blank?

        params = { **PARAMS, portfolio_pid: id }
        query = URI.encode_www_form(params)

        # TODO: check if collection has url_override and use it (from @collection)

        URI::HTTPS.build(host: HOST, path: PATH, query: query).to_s
      end

      # @return [String, nil]
      def collection_id
        data[:collection_id]
      end

      def electronic?
        true
      end
    end
  end
end
