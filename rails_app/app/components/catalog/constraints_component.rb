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
          **)
    end

    def initialize(edit_search: true, **)
      super(**)

      @edit_search = edit_search
      @heading_classes = nil
    end

    # Always render the component, even when there are no constraints
    # This allows us to show "Searching for all" when browsing without filters
    #
    # @return [Boolean] true
    def render?
      true
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

    # Creates a facet constraint presenter for a single facet item
    #
    # @param facet_field_presenter [Blacklight::FacetFieldPresenter] presenter for the facet field
    # @param facet_config [Blacklight::Configuration::FacetField] configuration for the facet
    # @param facet_item [String] the facet item
    # @return [Blacklight::ConstraintPresenter] constraint presenter for the facet item
    def facet_constraint_presenter(facet_field_presenter, facet_config, facet_item)
      facet_config.constraint_presenter.new(facet_item_presenter: facet_field_presenter.item_presenter(facet_item),
                                            field_label: facet_field_presenter.label)
    end

    # Creates a constraint presenter for an inclusive facet (multiple values)
    #
    # @param facet_field_presenter [Blacklight::FacetFieldPresenter] presenter for the facet field
    # @param facet_config [Blacklight::Configuration::FacetField] configuration for the facet
    # @param facet_item [Array] array of facet items
    # @param facet_field [Symbol, String] the facet field name
    # @return [Blacklight::ConstraintPresenter] constraint presenter for the inclusive facet
    def inclusive_facet_constraint_presenter(facet_field_presenter, facet_config, facet_item, facet_field)
      item_presenter = Blacklight::InclusiveFacetItemPresenter.new(
        facet_item, facet_config, helpers, facet_field
      )
      facet_config.constraint_presenter.new(
        facet_item_presenter: item_presenter,
        field_label: facet_field_presenter.label
      )
    end

    # Returns a heading tag for the constraints section
    #
    # @return [ActiveSupport::SafeBuffer, nil] constraints heading html
    def constraints_heading
      return unless @render_headers

      tag.h2(
        t('blacklight.search.filters.title'),
        class: @heading_classes
      )
    end

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
