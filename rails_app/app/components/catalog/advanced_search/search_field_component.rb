# frozen_string_literal: true

module Catalog
  module AdvancedSearch
    # Renders search fields for advanced search form
    class SearchFieldComponent < ViewComponent::Base
      # @param field [Blacklight::Configuration::SearchField] field
      # @param query [String] query value from clause parameters
      # @param index [Integer] the position in the list of advanced search search fields
      # @param options [Hash]
      def initialize(field:, query:, index:, **options)
        @field = field
        @query = query
        @index = index
        @options = options
      end
    end
  end
end
