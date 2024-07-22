# frozen_string_literal: true

module Find
  # Local component copied from Blacklight v8.1.0 to accommodate range search fields
  # - AdvancedSearchForm Stimulus controller attached
  class AdvancedSearchFormComponent < Blacklight::AdvancedSearchFormComponent
    private

    def initialize_search_field_controls
      search_fields.values.each.with_index do |field, i|
        with_search_field_control do
          render(Find::AdvancedSearch::SearchFieldComponent.new(field: field,
                                                                query: query_for_search_clause(field.key),
                                                                index: i))
        end
      end
    end
  end
end
