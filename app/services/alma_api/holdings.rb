# frozen_string_literal: true

module AlmaApi
  # Holdings data service
  class Holdings
    class << self
      def find(mms_id)
        availability_data = Alma::Bib.get_availability([mms_id])
        holdings(mms_id, holding_data(mms_id, availability_data))
      end

      def find_many; end

      private

      def holding_data(mms_id, availability_data)
        availability_data.availability.dig(mms_id, :holdings)
      end

      def holdings(mms_id, holding_data)
        holding_data.map do |holding|
          AlmaApi::Holding.new(mms_id, holding)
        end
      end
    end
  end
end
