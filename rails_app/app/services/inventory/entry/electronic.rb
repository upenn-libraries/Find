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

      # User-friendly display value for inventory entry status
      # Electronic resources _should_ *ALWAYS* be "Available" - otherwise we shouldn't show them. If this proves to be
      # true we can simplify this.
      # @return [String, nil] status
      def human_readable_status
        case status
        when Constants::ELEC_AVAILABLE then I18n.t('alma.availability.available.electronic.status')
        when Constants::CHECK_HOLDINGS then I18n.t('alma.availability.check_holdings.electronic.status')
        when Constants::ELEC_UNAVAILABLE then I18n.t('alma.availability.unavailable.electronic.status')
        else
          status&.capitalize
        end
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

      # @return [String, nil]
      def href
        return nil if id.blank?

        params = { **PARAMS, portfolio_pid: id }
        query = URI.encode_www_form(params)

        URI::HTTPS.build(host: HOST, path: PATH, query: query).to_s
      end

      # @return [String, nil]
      def collection_id
        data[:collection_id]
      end

      # @return [Boolean]
      def electronic?
        true
      end
    end
  end
end
