# frozen_string_literal: true

module Discover
  # Placeholder component that renders initial page load and fetches results turbo-frame
  class ResultsSkeletonComponent < ViewComponent::Base
    ICON_CLASS_MAPPINGS = {
      Discover::Configuration::Blacklight::Find::SOURCE => %w[bi bi-book],
      Discover::Configuration::Blacklight::FindingAids::SOURCE => %w[bi bi-archive],
      Discover::Configuration::PSE::Museum::SOURCE => %w[card-icon discover-icon discover-icon-museum],
      Discover::Configuration::PSE::ArtCollection::SOURCE => %w[bi bi-brush]
    }.freeze

    attr_reader :source, :query, :disabled, :results

    # @param [String] source
    # @param [String] query
    # @param [Boolean] disabled
    def initialize(source:, results: [], query: '', disabled: false)
      @source = source
      @query = query
      @results = results
      @disabled = disabled
    end

    # @return [TrueClass, FalseClass]
    def results?
      results.any?
    end

    # @return [String]
    def id
      label.downcase.split(' ').join('-')
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
