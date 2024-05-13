# frozen_string_literal: true

module Shelf
  module Entry
    # Shelf entry for a hold in Alma.
    class IlsHold < Base
      def id
        raw_data['request_id']
      end

      def title
        raw_data['title']
      end

      def author
        raw_data['author']
      end

      # Returning mms_id for holds that are NOT resource sharing holds.
      def mms_id
        return nil if resource_sharing?

        raw_data['mms_id']
      end

      def status
        if on_hold_shelf?
          "#{raw_data['request_status'].humanize} until #{format_date(expiry_date)}"
        else
          raw_data['request_status']&.titleize
        end
      end

      # @return [Time]
      def last_updated_at
        Time.zone.parse(raw_data['request_time'])
      end

      def barcode
        raw_data['barcode']
      end

      def on_hold_shelf?
        raw_data['request_status'] == 'ON_HOLD_SHELF'
      end

      # Date request expires
      def expiry_date
        Time.zone.parse(raw_data['expiry_date'])
      end

      # Return pickup location.
      def pickup_location
        raw_data['pickup_location']
      end

      # Returns true if its a hold created by resource sharing for an item from another library.
      def resource_sharing?
        raw_data.key?('resource_sharing')
      end

      def system
        ILS
      end

      def type
        :hold
      end

      def ils_hold?
        true
      end
    end
  end
end
