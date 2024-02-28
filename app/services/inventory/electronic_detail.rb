# frozen_string_literal: true

module Inventory
  # Grab additional data for electronic items
  class ElectronicDetail
    attr_accessor :mms_id, :portfolio_id, :collection_id

    def initialize(mms_id:, holding_id:, collection_id:)
      @mms_id = mms_id
      @holding_id = holding_id
      @collection_id = collection_id
    end

    def coverage
      # TODO: get machine-readable coverage data? or maybe what we get from availability is enough
    end

    # Accumulate notes via secondary API calls
    # @return [Array]
    def notes
      [portfolio['authentication_note'],
       portfolio['public_note'],
       collection['authentication_note'],
       collection['public_note'],
       service['authentication_note'],
       service['public_note']]
    end

    private

    def portfolio
      @portfolio ||= Alma::Electronic.get(collection_id: collection_id, service_id: nil,
                                          portfolio_id: portfolio_id)&.data || {}
    end

    def collection
      @collection ||= Alma::Electronic.get(collection_id: collection_id)&.data || {}
    end

    def service
      @service ||= Alma::Electronic.get(
        collection_id: collection_id,
        service_id: portfolio.dig('electronic_collection', 'service', 'value')
      )&.data || {}
    end
  end
end
