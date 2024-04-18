# frozen_string_literal: true

# Namespace for component that renders results from sources other than the catalog
module AdditionalResults
  # Renders container for results from sources other than the catalog
  class AdditionalResultsComponent < ViewComponent::Base
    include AdditionalResults::SourceHelper

    renders_many :results_sources, AdditionalResults::ResultsSourceComponent

    # @param query [String] the search term
    # @param options [Hash] options for the component
    # @option options [String] :class class(es) to apply to the component template
    def initialize(query:, **options)
      @query = query
      @classes = Array.wrap(options[:class])&.join(' ')
    end

    # @return [Boolean] true if a search term has been provided
    def render?
      @query.present?
    end
  end
end
