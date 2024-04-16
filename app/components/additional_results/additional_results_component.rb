# frozen_string_literal: true

module AdditionalResults
  # Renders container for additional results
  class AdditionalResultsComponent < ViewComponent::Base
    def initialize(query:, **options)
      @query = query
      @sources = Settings.additional_results_sources
      @classes = Array.wrap(options[:class])&.join(' ')
    end
  end
end
