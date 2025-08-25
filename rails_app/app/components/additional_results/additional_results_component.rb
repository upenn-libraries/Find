# frozen_string_literal: true

# Namespace for component that renders results from sources other than the catalog
module AdditionalResults
  # Renders container for results from sources other than the catalog
  class AdditionalResultsComponent < ViewComponent::Base
    include Turbo::FramesHelper
    include AdditionalResults::SourceHelper

    renders_many :results_sources, AdditionalResults::ResultsSourceComponent

    # @param query [String] the search term
    # @param hidden_sources_param [String, nil] the hide_additional_sources param value
    # @param sources [Array<String>] array of all specified additional results sources
    # @param options [Hash] options for the component
    def initialize(query:, hidden_sources_param:, sources: [], **options)
      @query = query
      @sources = sources
      @hidden_sources = hidden_sources_param.to_s.split(',')
      @classes = Array.wrap(options[:class])&.join(' ')

      build_results_sources
    end

    # @return [Boolean] true if a search term has been provided and there are unhidden additional sources
    def render?
      @query.present? && filtered_sources.any?
    end

    private

    # @return [Array<String>] array of remaining sources after filtering out invalid or those hidden by param
    def filtered_sources
      return [] if @hidden_sources.include?('all')

      @sources.reject { |source| !valid?(source) || @hidden_sources.include?(source) }
    end

    def build_results_sources
      filtered_sources.each do |source|
        with_results_source(source, class: @classes)
      end
    end
  end
end
