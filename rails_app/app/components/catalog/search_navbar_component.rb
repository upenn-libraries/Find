# frozen_string_literal: true

module Catalog
  # Overrides component from Blacklight 9.0.0
  #
  # Takes an id prefix so a page can carry more than one search box. The home page renders its own
  # alongside the header's, and without distinct ids the two boxes would share element ids.
  class SearchNavbarComponent < Blacklight::SearchNavbarComponent
    # @param blacklight_config [Blacklight::Configuration]
    # @param id_prefix [String, nil] prepended to the ids inside this search box
    def initialize(blacklight_config:, id_prefix: nil)
      @id_prefix = id_prefix
      super(blacklight_config: blacklight_config)
    end

    def search_bar_component
      search_bar_component_class.new(
        url: helpers.search_action_url,
        advanced_search_url: helpers.search_action_url(action: 'advanced_search'),
        params: helpers.search_state.params_for_search.except(:qt),
        autocomplete_path: suggest_index_catalog_path,
        id_prefix: @id_prefix
      )
    end
  end
end
