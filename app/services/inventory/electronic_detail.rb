# frozen_string_literal: true

module Inventory
  # Grab additional data for electronic items
  class ElectronicDetail
    attr_accessor :mms_id, :portfolio_id, :collection_id

    def initialize(mms_id:, portfolio_id:, collection_id:)
      @mms_id = mms_id
      @portfolio_id = portfolio_id
      @collection_id = collection_id
    end

    def coverage
      # TODO: get machine-readable coverage data? or maybe what we get from availability is enough
    end

    # Accumulate notes via secondary API calls
    # @return [Array]
    def notes
      # TODO: get notes from portfolio. if needed check collection (if available) and then service (if available) for
      #       notes. it looks like we can stop searching as soon as we get a non-blank value for either public_note or
      #       authentication_note.
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
