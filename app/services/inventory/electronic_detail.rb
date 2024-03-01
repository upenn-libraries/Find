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
      notes = Notes.new(portfolio)

      return notes.all if collection_id.blank?

      notes.update(service) if service_id && notes.missing?

      notes.update(collection) if notes.missing?

      notes.all
    end

    private

    # @return [Hash]
    def portfolio
      return {} if portfolio_id.blank?

      @portfolio ||= Alma::Electronic.get(collection_id: collection_id, service_id: nil,
                                          portfolio_id: portfolio_id)&.data || {}
    end

    # @return [Hash]
    def collection
      return {} if collection_id.blank?

      @collection ||= Alma::Electronic.get(collection_id: collection_id)&.data || {}
    end

    # @return [Hash]
    def service
      return {} if service_id.blank? || collection_id.blank?

      @service ||= Alma::Electronic.get(
        collection_id: collection_id,
        service_id: service_id
      )&.data || {}
    end

    # @return [String, Nil]
    def service_id
      @service_id = portfolio.dig('electronic_collection', 'service', 'value')
    end

    # Represents notes from Alma electronic api
    class Notes
      attr_accessor :data

      FIELDS = %w[public_note authentication_note].freeze

      # @param [Hash] data
      def initialize(data = {})
        @data = fetch(data)
      end

      # @param [Hash] data
      # @return [Hash]
      def fetch(data)
        FIELDS.index_with { |field| data[field] }
      end

      # @return [Boolean]
      def missing?
        data.values.any?(&:blank?)
      end

      # Create a new stored data hash that updates blank notes with new note data, while preserving the non-blank notes.
      #
      # @param [Hash] new_data
      # @return [Hash, Nil]
      def update(new_data)
        new_notes = fetch(new_data)
        return if new_notes.values.all?(&:blank?)

        @data = @data.merge(new_notes) { |_k, old_value, new_value| old_value.presence || new_value.presence }
      end

      # @return [Array]
      def all
        data.values.compact_blank
      end
    end
  end
end
