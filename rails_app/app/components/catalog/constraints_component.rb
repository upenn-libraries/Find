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
  end
end
