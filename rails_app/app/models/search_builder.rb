# frozen_string_literal: true

# This class extends Blacklight::SearchBuilder to add additional functionality
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior

  self.default_processor_chain += [:facets_for_advanced_search_form]

  # Merge the advanced search form parameters into the solr parameters
  # @param [Hash] solr_p the current solr parameters
  # @return [Hash] the solr parameters with the additional advanced search form parameters
  def facets_for_advanced_search_form(solr_p)
    return unless search_state.controller&.action_name == 'advanced_search' &&
                  blacklight_config.advanced_search[:form_solr_parameters]

    solr_p.merge!(blacklight_config.advanced_search[:form_solr_parameters])
  end
end
