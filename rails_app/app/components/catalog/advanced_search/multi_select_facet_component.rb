# frozen_string_literal: true

module Catalog
  module AdvancedSearch
    # Multi select facet component using TomSelect
    class MultiSelectFacetComponent < Blacklight::Component
      def initialize(facet_field:)
        @facet_field = facet_field
      end

      # @return [Array<Blacklight::FacetFieldPresenter>] array of facet field presenters
      def presenters
        return [] unless @facet_field.paginator

        return to_enum(:presenters) unless block_given?

        @facet_field.paginator.items.each do |item|
          yield @facet_field.facet_field.item_presenter.new(item, @facet_field.facet_field, helpers, @facet_field.key, @facet_field.search_state)
        end
      end

      # @return [Hash] HTML attributes for the select element
      def select_attributes
        {
          name: "f_inclusive[#{@facet_field.key}][]",
          placeholder: @facet_field.label,
          multiple: true,
          data: {
            controller: 'multi-select',
            multi_select_plugins_value: select_plugins.to_json
          }
        }
      end

      # @return [Array<String>] array of TomSelect plugins
      def select_plugins
        %w[checkbox_options caret_position input_autogrow clear_button remove_button]
      end
    end
  end
end
