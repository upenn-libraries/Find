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

    # @return [String]
    def modal_content
      t("discover.results.location_modal.#{source}.content_html").html_safe
    end

    # @return [String]
    def location_modal_id
      "#{id}-location-modal"
    end
  end
end
