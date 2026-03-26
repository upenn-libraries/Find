# frozen_string_literal: true

module Catalog
  # Local component overriding version from Blacklight v9.0
  class ConstraintsComponent < Blacklight::ConstraintsComponent
    # Constraints are stored and used to display search history - with this method, we initialize the
    # ConstraintsComponent in a way that displays well in a table (and without a start-over button)
    def self.for_search_history(**)
      new(tag: :span,
          render_headers: false,
          id: nil,
          query_constraint_component: Catalog::SearchHistoryConstraintLayoutComponent,
          facet_constraint_component_options: { layout: Catalog::SearchHistoryConstraintLayoutComponent },
          start_over_component: nil,
          edit_search: false,
          show_all_constraint: false,
          **)
    end

    def initialize(edit_search: true, show_all_constraint: true, **)
      super(**)

      @edit_search = edit_search
      @show_all_constraint = show_all_constraint
      @heading_classes = nil
    end

    # Render the component when there are constraints, or when showing "All" is enabled
    #
    # @return [Boolean]
    def render?
      !no_constraints? || @show_all_constraint
    end

    # Checks if there are no search constraints (query or facets)
    #
    # @return [Boolean] true if no constraints present
    def no_constraints?
      @search_state.query_param.blank? &&
        @search_state.filters.empty? &&
        clause_queries_blank?
    end

    # Renders an "All" constraint pill when there are no search constraints
    #
    # @return [ActiveSupport::SafeBuffer] HTML for the "All" constraint
    def all_constraint
      tag.span(class: 'btn-group applied-filter constraint filter mx-1') do
        tag.span(class: 'constraint-value btn btn-outline-secondary') {
          tag.span(t('blacklight.search.filters.all'), class: 'filter-value')
        } + all_constraint_remove_button
      end
    end

    # Renders the remove button for the "All" constraint
    #
    # @return [ActiveSupport::SafeBuffer] HTML for the remove button
    def all_constraint_remove_button
      helpers.link_to(helpers.root_path, class: 'btn btn-outline-secondary remove') do
        render(Blacklight::Icons::RemoveComponent.new(aria_hidden: true)) +
          tag.span(t('blacklight.search.filters.remove.value', value: 'All'), class: 'visually-hidden')
      end
    end

    private

    # Checks if advanced search clause queries are blank
    #
    # @return [Boolean] true if no clause queries present
    def clause_queries_blank?
      clauses = @search_state.params[:clause]
      return true if clauses.blank?

      clauses.values.all? { |c| c[:query].blank? }
    end
  end
end
