# frozen_string_literal: true

module Shelf
  module Entry
    # Abstract class that all Shelf entry classes inherit from. Establishes API that subclasses should adhere to.
    class Base
      ILL = :ill
      ILS = :ils

      attr_reader :raw_data

      def initialize(raw_data)
        @raw_data = raw_data
      end

      # Identifier for the transaction, request or hold.
      def id
        raise NotImplementedError
      end

      # Title to best describe the object.
      def title
        raise NotImplementedError
      end

      # Author/Creator of the object.
      def author
        raise NotImplementedError
      end

      # Identifier for the object.
      def mms_id
        raise NotImplementedError
      end

      # Status of the loan/transaction/request.
      def status
        raise NotImplementedError
      end

      # Date of last update for this request. Used for sorting.
      def last_updated_at
        raise NotImplementedError
      end

      # System entry is found in.
      #
      # @return [Symbol]
      def system
        raise NotImplementedError
      end

      # Type of entry within System.
      def type
        raise NotImplementedError
      end

      # Not all types will have a due date - to support sorting use nil by default
      # @return [nil]
      def due_date
        nil
      end

      # Method to format date to user-friendly string. Does not include time.
      #
      # @param [Time] date
      # @return [String]
      def format_date(date)
        date.in_time_zone.strftime('%m/%d/%y')
      end

      # Based on the title, determines if work is a boundwith.
      # Note: This will identify most, but not all boundwiths records because some boundwith records represent
      #       the first bound item as the host record.
      #
      # @return [Boolean]
      def boundwith?
        title.starts_with?(PennMARC::Title::HOST_BIB_TITLE)
      end

      def ils_loan?
        false
      end

      def ils_hold?
        false
      end

      def ill_transaction?
        false
      end
    end
  end
end
