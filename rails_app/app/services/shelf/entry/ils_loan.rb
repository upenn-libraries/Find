# frozen_string_literal: true

module Shelf
  module Entry
    # Shelf entry for a loan in Alma.
    class IlsLoan < Base
      def id
        raw_data['loan_id']
      end

      def title
        raw_data['title']
      end

      def author
        raw_data['author']
      end

      def mms_id
        return nil if resource_sharing?

        raw_data['mms_id']
      end

      def status
        return nil unless due_date

        if due_date >= Time.current
          format_date(due_date)
        else
          'OVERDUE'
        end
      end

      def barcode
        raw_data['item_barcode']
      end

      # @return [Time]
      def due_date
        Time.zone.parse(raw_data['due_date'])
      end

      # @return [Time]
      def last_updated_at
        date = raw_data['last_renew_date'] || raw_data['loan_date']
        Time.zone.parse(date)
      end

      # Returns true if item is renewable. Raises an error if the renewable attribute is not available in the
      # data provided.
      def renewable?
        raise Shelf::Service::AlmaRequestError, 'Renewable attribute unavailable' if raw_data['renewable'].nil?

        raw_data['renewable']
      end

      # Returns true if its a loan is for a resource sharing item from another library.
      def resource_sharing?
        raw_data.dig('library', 'value') == 'RES_SHARE'
      end

      def system
        ILS
      end

      def type
        :loan
      end

      def ils_loan?
        true
      end
    end
  end
end
