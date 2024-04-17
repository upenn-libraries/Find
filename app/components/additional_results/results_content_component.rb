# frozen_string_literal: true

module AdditionalResults
  # Renders results from sources other than the catalog
  class ResultsContentComponent < ViewComponent::Base
    def initialize(query:, **options)
      @query = query
      @classes = Array.wrap(options[:class])&.join(' ')
      @validated_sources = AdditionalResults.results_sources
    end
  end
end
