# frozen_string_literal: true

module Catalog
  # Overrides component from Blacklight 9.2.1 to pass in local class to search bar component
  class SearchNavbarComponent < Blacklight::SearchNavbarComponent
    def search_bar_component
      search_bar_component_class.new(
        url: helpers.search_action_url,
        classes: ['fi-search-box'],
        advanced_search_url: helpers.search_action_url(action: 'advanced_search'),
        params: helpers.search_state.params_for_search.except(:qt),
        autocomplete_path: suggest_index_catalog_path
      )
    end
  end
end
