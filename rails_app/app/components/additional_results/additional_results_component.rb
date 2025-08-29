# frozen_string_literal: true

# Namespace for component that renders results from sources other than the catalog
module AdditionalResults
  # Renders container for results from sources other than the catalog
  class AdditionalResultsComponent < ViewComponent::Base
    include Turbo::FramesHelper
    include AdditionalResults::SourceHelper

    renders_many :results_sources, AdditionalResults::ResultsSourceComponent

    # @param params [Hash] the URL parameters, optionally including search term and sources to exclude
    # @param sources [Array<String>] array of all specified additional results sources
    # @param options [Hash] options for the component
    def initialize(params:, sources: [], **options)
      @params = params
      @sources = sources
      @classes = Array.wrap(options[:class])&.join(' ')
    end

    # Adds ResultsSourceComponent for each visible (not specified to be hidden) source
    # @return void
    def before_render
      filtered_sources.each do |source|
        with_results_source(source, class: @classes)
      end
    end

    # @return [Boolean] true if a search term has been provided and there are unhidden additional sources
    def render?
      query.present? && filtered_sources.any?
    end

    private

    # @return [Array<String>] array of remaining sources after filtering out invalid or those hidden by param
    def filtered_sources
      return [] if excluded_sources.include?('all')

      @sources.reject { |source| !valid?(source) || excluded_sources.include?(source) }
    end

    # Returns the search query string from the request parameters
    # @return [String, nil] The value of the `:q` parameter if present, otherwise `nil`
    def query
      @query ||= @params[:q]
    end

    # @return [Array<String>] A comma-separated list of source ids to exclude (or 'all')
    def excluded_sources
      @excluded_sources ||= @params[:exclude_extra].to_s.split(',') || []
    end
  end
end
