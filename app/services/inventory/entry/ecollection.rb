# frozen_string_literal: true

module Inventory
  class Entry
    # Holding class for inventory derived from an Alma E-Collection record
    class Ecollection < Inventory::Entry
      alias collection_id id

      # @return [String, nil]
      def id
        data[:id]
      end

      # @return [String, nil]
      def description
        data[:public_name_override].presence || data[:public_name].presence
      end

      # @return [String]
      def status
        Constants::ELEC_AVAILABLE
      end

      # @return [String]
      def human_readable_status
        I18n.t('alma.availability.available.electronic.status')
      end

      # @return [nil]
      def location
        nil
      end

      # @return [nil]
      def policy
        nil
      end

      # @return [nil]
      def format
        nil
      end

      # @return [nil]
      def coverage_statement
        nil
      end

      # @return [String, nil]
      def href
        data[:url_override].presence || data[:url]
      end

      # @return [Boolean]
      def electronic?
        true
      end

      # @return [Boolean]
      def ecollection?
        true
      end
    end
  end
end
