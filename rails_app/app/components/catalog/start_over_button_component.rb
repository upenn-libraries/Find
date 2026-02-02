# frozen_string_literal: true

module Catalog
  # Local component copied from Blacklight v9.0
  class StartOverButtonComponent < Blacklight::Component
    SVG_PATH = 'M9 9L15 15M15 9L9 15M7.8 21H16.2C17.8802 21 18.7202 21 19.362 20.673' \
               'C19.9265 20.3854 20.3854 19.9265 20.673 19.362C21 18.7202 21 17.8802 21 16.2V7.8' \
               'C21 6.11984 21 5.27976 20.673 4.63803C20.3854 4.07354 19.9265 3.6146 19.362 3.32698' \
               'C18.7202 3 17.8802 3 16.2 3H7.8C6.11984 3 5.27976 3 4.63803 3.32698' \
               'C4.07354 3.6146 3.6146 4.07354 3.32698 4.63803C3 5.27976 3 6.11984 3 7.8V16.2' \
               'C3 17.8802 3 18.7202 3.32698 19.362C3.6146 19.9265 4.07354 20.3854 4.63803 20.673' \
               'C5.27976 21 6.11984 21 7.8 21Z'

    def call
      link_to start_over_path, class: 'catalog_startOverLink btn btn-light',
                               aria: { label: t('blacklight.search.start_over') },
                               data: { bs_toggle: 'tooltip', bs_title: t('blacklight.search.start_over') } do
        helpers.tag.svg(
          width: 20, height: 20, viewBox: '0 0 24 24', fill: 'none',
          xmlns: 'http://www.w3.org/2000/svg', aria: { hidden: true }
        ) do
          helpers.tag.path(
            d: SVG_PATH, stroke: 'currentColor',
            'stroke-width': 2, 'stroke-linecap': 'round', 'stroke-linejoin': 'round'
          )
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
