# frozen_string_literal: true

module AdditionalResults
  module ResultsSource
    # Renders additional results from a specified source
    class ResultsSourceComponent < ViewComponent::Base
      attr_reader :query, :source

      def initialize(query:, source:)
        @query = query
        @source = source
      end

      def call
        render AdditionalResults::ResultsSource::Articles::SummonComponent.new(query: query) if source ==
                                                                                                'summon'
      end
    end
  end
end
