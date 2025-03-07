# frozen_string_literal: true

module Discover
  # Placeholder component that renders initial page load and fetches results turbo-frame
  class ResultsSkeletonComponent < ViewComponent::Base
    ICON_CLASS_MAPPINGS = {
      Discover::Configuration::Blacklight::Find::SOURCE => %w[bi bi-book],
      Discover::Configuration::Blacklight::FindingAids::SOURCE => %w[bi bi-archive],
      Discover::Configuration::PSE::Museum::SOURCE => %w[card-icon discover-icon discover-icon-museum],
      Discover::Configuration::Database::ArtCollection::SOURCE => %w[bi bi-brush]
    }.freeze

    attr_reader :source, :query, :disabled, :results, :count

    # @param source [String, Symbol]
    # @param query [String]
    # @param results [Array]
    # @param disabled [Boolean]
    def initialize(source:, query: '', results: [], disabled: false, count: Configuration::RESULT_MAX_COUNT)
      @source = source.to_s
      @query = query
      @results = results
      @disabled = disabled
      @count = count
    end

    # @return [Boolean]
    def results?
      results.any?
    end

    # @return [String]
    def id
      label.downcase.split(' ').join('-')
    end

    # @return [String]
    def turbo_frame_id
      "#{id}-turbo-frame"
    end

    # @return [String]
    def results_button_id
      "#{id}-results-button"
    end

    # @return [String]
    def label
      t("discover.results.source.#{source}.label")
    end

    # @return [Array<String>]
    def icon_classes
      ICON_CLASS_MAPPINGS.fetch(source.to_sym, [])
    end
  end
end
