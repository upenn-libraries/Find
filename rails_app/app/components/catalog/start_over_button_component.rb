# frozen_string_literal: true

module Catalog
  # Local component copied from Blacklight v9.0
  class StartOverButtonComponent < Blacklight::Component
    def call
      link_to start_over_path, class: 'catalog_startOverLink btn btn-light',
                               aria: { label: t('blacklight.search.start_over') },
                               data: { bs_toggle: 'tooltip', bs_title: t('blacklight.search.start_over') } do
        helpers.tag.svg(width: 18, height: 18, viewBox: '0 0 24 24', fill: 'none', xmlns: 'http://www.w3.org/2000/svg',
                        aria: { hidden: true }) do
          helpers.tag.path(d: 'M9 3H15M3 6H21M19 6L18.2987 16.5193C18.1935 18.0975 18.1409 18.8867 17.8 19.485C17.4999 20.0118 17.0472 20.4353 16.5017 20.6997C15.882 21 15.0911 21 13.5093 21H10.4907C8.90891 21 8.11803 21 7.49834 20.6997C6.95276 20.4353 6.50009 20.0118 6.19998 19.485C5.85911 18.8867 5.8065 18.0975 5.70129 16.5193L5 6M10 10.5V15.5M14 10.5V15.5',
                          stroke: 'currentColor', 'stroke-width': 2, 'stroke-linecap': 'round', 'stroke-linejoin': 'round')
        end
      end
    end

    private

    ##
    # Get the path to the search action with any parameters (e.g. view type)
    # that should be persisted across search sessions.
    def start_over_path(query_params = params)
      h = {}
      current_index_view_type = helpers.document_index_view_type(query_params)
      h[:view] = current_index_view_type unless current_index_view_type == helpers.default_document_index_view_type

      helpers.search_action_path(h)
    end
  end
end
