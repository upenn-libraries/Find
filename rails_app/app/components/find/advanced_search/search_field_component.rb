# frozen_string_literal: true

module Find
  module AdvancedSearch
    # Renders search fields for advanced search form
    class SearchFieldComponent < ViewComponent::Base
      # @param field [Blacklight::Configuration::SearchField] field
      # @param params [ActionController::Parameters] parameters from incoming request
      # @param  index [Integer] the position in the list of advanced search search fields
      # @param options [Hash]
      def initialize(field:, params:, index:, **options)
        @field = field
        @params = params
        @index = index
        @options = options
      end

      # Get field's incoming clause params query value
      # Copied from Blacklight::AdvancedSearchFormComponent v8.1.0 private method to support accessing this value
      # elsewhere
      # @param key [String] search field
      def query_for_search_clause(key)
        field = (@params[:clause] || {}).values.find { |value| value['field'].to_s == key.to_s }

        field&.dig('query')
      end
    end
  end
end
