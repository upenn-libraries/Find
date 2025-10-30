# frozen_string_literal: true

module Suggester
  module SpecHelpers
    # @return [Class]
    def mock_engine_class(actions: [], completions: [], success: false)
      Class.new(Suggester::SuggestionEngine) do
        define_method(:actions) { actions }
        define_method(:completions) { completions }
        define_method(:success?) { success }
      end
    end

    # @return [Class]
    def mock_engine_with_actions
      mock_engine_class(actions: Suggester::Suggestion.new(entries: [{
                                                             label: 'Search titles for "query"',
                                                             url: 'https://find.library.upenn.edu/?field=title&q=query'
                                                           }]), success: true)
    end

    # @return [Class]
    def mock_engine_with_completions
      mock_engine_class(completions: Suggester::Suggestion.new(entries: ['query syntax', 'query language',
                                                                         'query errors', 'adversarial queries']),
                        success: true)
    end
  end
end
