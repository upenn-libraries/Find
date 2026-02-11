# frozen_string_literal: true

module Discover
  # Renders a single result record entry
  class RecordComponent < ViewComponent::Base
    attr_reader :presenter

    delegate(*Discover::Record::BasePresenter::DISPLAY_TERMS, to: :presenter)

    # @param record [Hash]
    # @param source [String]
    def initialize(record:, source:)
      @presenter = create_presenter(record: record, source: source)
    end

    # @param record [Hash]
    # @param source [String, nil]
    # @return [Discover::Record::BasePresenter]
    def create_presenter(record:, source:)
      case source&.to_sym
      when Configuration::PSE::Museum::SOURCE
        Discover::Record::MuseumPresenter.new(record: record)
      else
        Discover::Record::BasePresenter.new(record: record)
      end
    end
  end
end
