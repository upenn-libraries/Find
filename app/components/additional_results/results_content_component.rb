# frozen_string_literal: true

module AdditionalResults
  # Renders results inside Additional Results container
  class ResultsContentComponent < ViewComponent::Base
    attr_reader :query, :sources

    def initialize(query:, **options)
      @query = query
      @sources = Settings.additional_results_sources
      @classes = Array.wrap(options[:class])&.join(' ')
    end
  end
end
