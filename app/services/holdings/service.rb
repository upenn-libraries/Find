# frozen_string_literal: true

module Holdings
  # Retrieves holdings from Alma real time availability api
  class Service
    class << self
      # @param [String] mms_id
      # @param [Integer] _brief_count
      # @return [Array<Hash>]
      def find(mms_id, _brief_count = 3)
        availability_data = Alma::Bib.get_availability([mms_id])
        holdings(mms_id, holding_data(mms_id, availability_data)).map(&:to_h)
      end

      def find_many; end

      private

      # @param [String] mms_id
      # @param [Alma::AvailabilityResponse] availability_data
      # @return [Array<Hash>]
      def holding_data(mms_id, availability_data)
        availability_data.availability.dig(mms_id, :holdings)
      end

      # @param [String] mms_id
      # @param [Array<Hash>] holding_data
      # @return [Array<Holdings::Holding>]
      def holdings(mms_id, holding_data)
        holding_data.map do |holding|
          Holdings::Holding.new(mms_id, holding)
        end
      end
    end
  end
end
