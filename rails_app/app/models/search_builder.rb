# frozen_string_literal: true

# This class extends Blacklight::SearchBuilder to add additional functionality
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior

  self.default_processor_chain += %i[facets_for_advanced_search_form
                                     massage_sort
                                     handle_standalone_boolean_operators]

  # When Solr encounters these in a query surrounded by space, they should be considered
  # literal characters and not boolean operators. Otherwise, bad or no results are returned.
  PROBLEMATIC_SOLR_BOOLEAN_OPERATORS = %w[+ \- !].freeze

  INDUCED_SORT = ['encoding_level_sort asc', 'updated_date_sort desc'].freeze
  RELEVANCE_SORT = ['score desc', 'publication_date_sort desc', 'title_sort asc'].freeze
  TITLE_SORT_ASC = ['title_sort asc', 'publication_date_sort desc'].freeze

  # Merge the advanced search form parameters into the solr parameters
  # @param solr_p [Hash] the current solr parameters
  def facets_for_advanced_search_form(solr_p)
    return unless (search_state.controller&.action_name == 'advanced_search') &&
                  blacklight_config.advanced_search[:form_solr_parameters]

    solr_p.merge!(blacklight_config.advanced_search[:form_solr_parameters])
  end

  # Applies an alternative sort order when a blank query is set to be sorted by score. This would require more work
  # to work with Advanced Search params (and may not be desirable), so we exit early in those cases to avoid munging
  # sort values. The modified sort prioritizes records as follows:
  #  - Records with inventory matching the access facet (if provided)
  #  - Encoding level rank (ascending)
  #  - Date last updated (descending)
  # @param solr_p [Hash] the current solr parameters
  def massage_sort(solr_p)
    return if solr_p.key?(:clause) || non_relevance_sort_parameter_present?(solr_p)
    return solr_p[:sort] = TITLE_SORT_ASC.join(',') if database_search?(solr_p)
    return solr_p[:sort] = RELEVANCE_SORT.join(',') if search_term_provided?(solr_p)

    solr_p[:sort] = INDUCED_SORT.dup.prepend(inventory_sort_addition(solr_p)).compact_blank.join(',')
  end

  # Escape certain Solr operators when they are found in the user's query surrounded by whitespace
  # @param solr_p [Hash] the current solr parameters
  def handle_standalone_boolean_operators(solr_p)
    return if solr_p[:q].blank?

    solr_p[:q] = solr_p[:q].gsub(/(?<=\s)([#{PROBLEMATIC_SOLR_BOOLEAN_OPERATORS.join}])(?=\s)/) { |match| "\\#{match}" }
  end

  private

  # @param solr_p [Hash]
  # @return [String, nil]
  def inventory_sort_addition(solr_p)
    case solr_p.dig(:f, :access_facet)&.join
    when PennMARC::Access::AT_THE_LIBRARY
      'min(def(physical_holding_count_i,0),1) desc' # has physical holdings
    when PennMARC::Access::ONLINE
      'min(def(electronic_portfolio_count_i,0),1) desc' # has portfolios
    end
  end

  # @param solr_p [Hash]
  # @return [Boolean]
  def non_relevance_sort_parameter_present?(solr_p)
    solr_p[:sort].present? && solr_p[:sort] != RELEVANCE_SORT.join(',')
  end

  # @param solr_p [Hash]
  # @return [Boolean, nil]
  def search_term_provided?(solr_p)
    solr_p.key?(:q) && solr_p[:q].present?
  end

  # @param solr_p [Hash]
  # @return [Boolean, nil]
  def database_search?(solr_p)
    solr_p.dig(:f, :format_facet)&.include?(PennMARC::Database::DATABASES_FACET_VALUE)
  end
end
