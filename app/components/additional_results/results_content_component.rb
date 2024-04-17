# frozen_string_literal: true

module AdditionalResults
  # Renders results from sources other than the catalog
  class ResultsContentComponent < ViewComponent::Base
    include AdditionalResults::SourcesHelper

    # @param query [String] the search term
    # @param options [Hash] options for the component
    # @option options [String] :class Class(es) to apply to the component template
    def initialize(query:, **options)
      @query = query
      @classes = Array.wrap(options[:class])&.join(' ')
      @validated_sources = results_sources
    end
  end
end
