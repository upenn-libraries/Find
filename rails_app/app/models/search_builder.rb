# frozen_string_literal: true

# This class extends Blacklight::SearchBuilder to add additional functionality
class SearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior

  self.default_processor_chain += %i[
    massage_sort
    handle_standalone_boolean_operators
  ]

  # When Solr encounters these in a query surrounded by space, they should be considered
  # literal characters and not boolean operators. Otherwise, bad or no results are returned.
  PROBLEMATIC_SOLR_BOOLEAN_OPERATORS = %w[+ \- !].freeze

  # Applies an alternative sort order when a query is set to be sorted by score. This would require more work
  # to work with Advanced Search params (and may not be desirable), so we exit early in those cases to avoid munging
  # sort values.
  # @see SortBuilder for sort implementation
  # @param solr_p [Hash] the current solr parameters
  def massage_sort(solr_p)
    return if advanced_search_params_present?(solr_p) || non_relevance_sort_parameter_present?(solr_p)
    return solr_p[:sort] = SortBuilder.title_sort_asc if database_search?

    sort_builder = SortBuilder.new(blacklight_params)

    solr_p[:sort] = search_term_provided?(solr_p) ? sort_builder.enriched_relevance_sort : sort_builder.browse_sort
  end

  # Escape certain Solr operators when they are found in the user's query surrounded by whitespace
  # @param solr_p [Hash] the current solr parameters
  def handle_standalone_boolean_operators(solr_p)
    return if solr_p[:q].blank?

    solr_p[:q] = solr_p[:q].gsub(/(?<=\s)([#{PROBLEMATIC_SOLR_BOOLEAN_OPERATORS.join}])(?=\s)/) { |match| "\\#{match}" }
  end

  private

  # @param solr_p [Hash]
  # @return [Boolean]
  def advanced_search_params_present?(solr_p)
    solr_p[:json].present?
  end

  # @param solr_p [Hash]
  # @return [Boolean]
  def non_relevance_sort_parameter_present?(solr_p)
    solr_p[:sort].present? && solr_p[:sort] != SortBuilder.relevance_sort
  end

  # @param solr_p [Hash]
  # @return [Boolean, nil]
  def search_term_provided?(solr_p)
    solr_p.key?(:q) && solr_p[:q].present?
  end

  # @return [Boolean, nil]
  def database_search?
    blacklight_params.dig(:f, :format_facet)&.include?(PennMARC::Database::DATABASES_FACET_VALUE)
  end
end
