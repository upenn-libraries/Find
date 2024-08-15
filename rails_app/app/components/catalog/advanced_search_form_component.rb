# frozen_string_literal: true

module Catalog
  # Local component copied from Blacklight v8.3.0 to accommodate range search fields
  # - AdvancedSearchForm Stimulus controller attached
  class AdvancedSearchFormComponent < Blacklight::AdvancedSearchFormComponent
    private

    def initialize_search_field_controls
      search_fields.values.each.with_index do |field, i|
        with_search_field_control do
          render(Catalog::AdvancedSearch::SearchFieldComponent.new(field: field,
                                                                   query: query_for_search_clause(field.key),
                                                                   index: i))
        end
      end
    end

    def initialize_constraints
      params = helpers.search_state.params_for_search.except :page, :f_inclusive, :q, :search_field, :op, :index, :sort

      adv_search_context = helpers.search_state.reset(params)

      constraints_text = render(Catalog::ConstraintsComponent.for_search_history(search_state: adv_search_context))

      return if constraints_text.blank?

      with_constraint do
        constraints_text
      end
    end
  end
end
