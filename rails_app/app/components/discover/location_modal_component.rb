# frozen_string_literal: true

module Discover
  # Modal component displaying physical location information for a source
  class LocationModalComponent < ViewComponent::Base
    attr_reader :presenter

    delegate(*Discover::Results::ResultsPresenter::VALUES, to: :presenter)

    # @param source [String, Symbol]
    def initialize(source:)
      @presenter = Discover::Results::ResultsPresenter.new(source: source)
    end
  end
end
