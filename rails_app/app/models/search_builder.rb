# frozen_string_literal: true

# This class extends Blacklight::SearchBuilder to add additional functionality
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior

  self.default_processor_chain += %i[facets_for_advanced_search_form
                                     intelligent_sort
                                     handle_standalone_boolean_operators]

  # When Solr encounters these in a query surrounded by space, they should be considered
  # literal characters and not boolean operators. Otherwise, bad or no results are returned.
  PROBLEMATIC_SOLR_BOOLEAN_OPERATORS = %w[+ \- !].freeze

  # Merge the advanced search form parameters into the solr parameters
  # @param solr_p [Hash] the current solr parameters
  def facets_for_advanced_search_form(solr_p)
    return unless search_state.controller&.action_name == 'advanced_search' &&
                  blacklight_config.advanced_search[:form_solr_parameters]

    solr_p.merge!(blacklight_config.advanced_search[:form_solr_parameters])
  end

  # Applies an alternative sort order when a blank query is set to be sorted by score.
  # The modified sort prioritizes records as follows:
  #  - Records with inventory matching the access facet (if provided)
  #  - Encoding level rank (ascending)
  #  - Date last updated (descending)
  # @param solr_p [Hash] the current solr parameters
  def intelligent_sort(solr_p)
    return unless intelligent_sort?

    return solr_p[:sort] = 'title_sort asc' if database_search?

    inventory_sort = case blacklight_params.dig(:f, :access_facet)&.join
                     when PennMARC::Access::AT_THE_LIBRARY
                       'min(def(physical_holding_count_i,0),1) desc'
                     when PennMARC::Access::ONLINE
                       'min(def(electronic_portfolio_count_i,0),1) desc'
                     end

    solr_p[:sort] = [inventory_sort, 'encoding_level_sort asc', 'updated_date_sort desc'].compact_blank.join(',')
  end

  # Escape certain Solr operators when they are found in the user's query surrounded by whitespace
  # @param solr_p [Hash] the current solr parameters
  def handle_standalone_boolean_operators(solr_p)
    return if solr_p[:q].blank?

    solr_p[:q] = solr_p[:q].gsub(/(?<=\s)([#{PROBLEMATIC_SOLR_BOOLEAN_OPERATORS.join}])(?=\s)/) { |match| "\\#{match}" }
  end

  private

  def intelligent_sort?
    blacklight_params[:q].blank? && blacklight_params[:sort] == 'score desc'
  end

  def database_search?
    blacklight_params.dig(:f, :format_facet)&.include?(PennMARC::Database::DATABASES_FACET_VALUE)
  end
end
