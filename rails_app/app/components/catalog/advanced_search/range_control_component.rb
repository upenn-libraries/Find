# frozen_string_literal: true

module Catalog
  module AdvancedSearch
    # Renders form controls for range search fields on advanced search page
    # - the start and end inputs have not been provided an html "name" attribute to prevent their
    #   submission on the advanced search page form
    # - RangeControl Stimulus Controller converts the value of the start and end inputs into a solr friendly
    #   range value upon form submission
    class RangeControlComponent < ViewComponent::Base
      # @param field [Blacklight::Configuration::SearchField] field
      # @param query [String] the field's query value from incoming clause parameters
      # @param index [Integer] the position in the list of advanced search search fields
      # @param options [Hash]
      def initialize(field:, query:, index:, **options)
        @field = field
        @query = query
        @index = index
        @options = options
      end

      # name attribute for input that stores clause params field name
      # @return [String (frozen)]
      def field_control_name
        clause_control_name('field')
      end

      # name attribute for input control that stores clause params field value
      # name attribute for clause query
      # @return [String]
      def field_control_value
        @field.key
      end

      # name attribute for input control that stores clause params query value
      # @return [String (frozen)]
      def query_control_name
        clause_control_name('query')
      end

      # id attribute for input controls given the provided name
      # @param name [String] the name of the clause params control field
      # @return [String]
      def control_id(name)
        ['clause', @index, name].join('_')
      end

      # Get the start point from incoming query params
      # @return [String, nil]
      def start_point
        endpoints_from_query_clause&.first&.strip
      end

      # Get the end point from incoming query params
      # @return [String, nil]
      def end_point
        endpoints_from_query_clause&.second&.strip
      end

      private

      # returns names for input controls that submit advanced search clause params
      # @param name [String] the name of the clause params control field
      # @return [String (frozen)]
      def clause_control_name(name)
        "clause[#{@index}][#{name}]"
      end

      # Get endpoints from incoming query clause params for use when rendering input fields
      # @return [Array, nil]
      def endpoints_from_query_clause
        return if @query.blank?

        @query&.tr('[*]', '')&.split('TO')
      end
    end
  end
end
