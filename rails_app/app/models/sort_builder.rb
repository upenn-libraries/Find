# frozen_string_literal: true

# Coordinates building solr sort strings
class SortBuilder
  PHYSICAL_INVENTORY_FIELD = :physical_holding_count_i
  ELECTRONIC_INVENTORY_FIELD = :electronic_portfolio_count_i

  ONLINE_ACCESS = PennMARC::Access::ONLINE
  PHYSICAL_ACCESS = PennMARC::Access::AT_THE_LIBRARY
  JOURNAL_PERIODICAL = PennMARC::Format::JOURNAL_PERIODICAL

  # @param blacklight_params [Hash]
  def initialize(blacklight_params)
    @access_facet = blacklight_params.dig(:f, :access_facet)&.join
    @sort = build_sort
  end

  delegate :enriched_relevance_sort, :browse_sort, to: :@sort

  # @return [String]
  def self.title_sort_asc
    SolrSort.compose(
      SolrSort.ascending(:title_sort),
      SolrSort.descending(:publication_date_sort)
    )
  end

  # @return [String]
  def self.relevance_sort
    SolrSort.compose(
      SolrSort.descending(:score),
      SolrSort.descending(:publication_date_sort),
      SolrSort.ascending(:title_sort)
    )
  end

  private

  # @return [SortBuilder::InventorySort, SortBuilder::DefaultSort]
  def build_sort
    case @access_facet
    when PHYSICAL_ACCESS
      InventorySort.new(primary_inventory: PHYSICAL_INVENTORY_FIELD, secondary_inventory: ELECTRONIC_INVENTORY_FIELD)
    when ONLINE_ACCESS
      InventorySort.new(primary_inventory: ELECTRONIC_INVENTORY_FIELD, secondary_inventory: PHYSICAL_INVENTORY_FIELD)
    else
      DefaultSort.new
    end
  end

  # Utility class that composes solr sort parameter and its components
  # Methods return solr sort expressions that can be composed into a full sort string.
  class SolrSort
    DEFAULT_TERM_BOOST_FIELD = :format_facet
    TERM_BOOST = 1
    DEFAULT_TERM_BOOST = 0
    FIELD_SCORE_LIMIT = 10
    # Joins sort orderings (e.g. "score desc", "publication_date_sort_desc") into a complete solr sort string
    # @param sort_orderings [Array]
    # @return [String] solr sort string (e.g. "score desc,publication_date_sort desc")
    def self.compose(*sort_orderings)
      sort_orderings.join(',')
    end

    # @param sort_value [Symbol, String]
    # @return [String]
    def self.ascending(sort_value)
      "#{sort_value} asc"
    end

    # @param sort_value [Symbol, String]
    # @return [String]
    def self.descending(sort_value)
      "#{sort_value} desc"
    end

    # Builds a solr min() function that caps a field's value at a given limit.
    # When limit is 1, this results in a boolean presence for the given field (i.e. 0 or 1).
    # @param field [Symbol, String] a numeric solr field
    # @param limit [Integer] the maximum score to allow
    # @return [String] solr min() function (e.g. "min(physical_holding_count_i,1)")
    def self.min_field_score(field:, limit: FIELD_SCORE_LIMIT)
      "min(#{field},#{limit})"
    end

    # Builds a solr sum() expression that combines a term-based boost with a minimum field count score (capped at 10).
    # Used to elevate records that match a given term (e.g. "Journal/Periodical" format_facet) while
    # still rewarding records with higher inventory counts.
    # @param field [Symbol, String] a numeric solr field to use as base score
    # @param term_boost_field [Symbol] the solr field to match against for a boost (default: :format_facet)
    # @param term_value [String] the value to match in the term field for a boost (default: "Journal/Periodical")
    # @param term_boost [Integer] the boost value when there is a matching term value (default: 1)
    # @param default_term_boost [Integer] the boost value when there is no matching term value (default: 0)
    # @return [String] solr sum() function
    def self.boosted_field_score(field:, term_boost_field: DEFAULT_TERM_BOOST_FIELD,
                                 term_value: JOURNAL_PERIODICAL, term_boost: TERM_BOOST,
                                 default_term_boost: DEFAULT_TERM_BOOST)
      boost = term_boost(field: term_boost_field, value: term_value, boost: term_boost,
                         default_boost: default_term_boost)
      count = min_field_score(field: field)
      "sum(#{boost},#{count})"
    end

    # Builds a solr max() expression that returns the higher of two scores.
    # @param first_score [String] a solr sort expression
    # @param second_score [String] a solr sort expression
    # @return [String] solr max() function
    def self.max_score(first_score, second_score)
      "max(#{first_score},#{second_score})"
    end

    # Builds a solr if(termfreq()) function that results in a boost based on whether
    # a field contains a given term.
    # @param field [String, Symbol] the solr field to match against for a boost
    # @param value [String] the value to match in the term field for a boost
    # @param boost [Integer] the boost value when there is a matching term value (default: 1)
    # @param default_boost [Integer] the boost value when there is no matching term value (default: 0)
    # @return [String] solr if(termfreq()) function
    def self.term_boost(field:, value:, boost: TERM_BOOST, default_boost: DEFAULT_TERM_BOOST)
      "if(termfreq(#{field},#{value}),#{boost},#{default_boost})"
    end
  end

  # Provides weighted sort functions based on a primary and secondary inventory fields
  # Useful for prioritizing a corresponding inventory type when the user has applied a specific access facet
  class InventorySort
    # @param primary_inventory [Symbol, String] the inventory field considered first when sorting
    # @param secondary_inventory [Symbol, String] the inventory field considered second when sorting
    def initialize(primary_inventory:, secondary_inventory:)
      @primary_inventory = primary_inventory
      @secondary_inventory = secondary_inventory
    end

    # @return [String]
    def enriched_relevance_sort
      SolrSort.compose(
        SolrSort.descending(:score),
        SolrSort.descending(:publication_date_sort),
        SolrSort.descending(journal_boosted_primary_inventory_score),
        SolrSort.descending(secondary_inventory_score),
        SolrSort.descending(:updated_date_sort)
      )
    end

    # @return [String]
    def browse_sort
      SolrSort.compose(
        SolrSort.descending(primary_inventory_presence),
        SolrSort.ascending(:encoding_level_sort),
        SolrSort.descending(:updated_date_sort)
      )
    end

    private

    # Journal/Periodical records with primary inventory are boosted relative to other formats
    # @return [String]
    def journal_boosted_primary_inventory_score
      SolrSort.boosted_field_score(field: @primary_inventory)
    end

    # Functions as boolean presence for the primary inventory because the primary inventory score is capped to 1
    # @return [String]
    def primary_inventory_presence
      SolrSort.min_field_score(field: @primary_inventory, limit: 1)
    end

    # Caps the secondary inventory score to 10
    # @return [String]
    def secondary_inventory_score
      SolrSort.min_field_score(field: @secondary_inventory)
    end
  end

  # Provides sort functions when no primary or secondary inventory specified
  # Useful when the user has not applied an access facet
  class DefaultSort
    ELECTRONIC_INVENTORY_BOOST = 1
    ELECTRONIC_JOURNAL_BOOST = 3
    PHYSICAL_JOURNAL_BOOST = 2

    # @return [String]
    def enriched_relevance_sort
      SolrSort.compose(
        SolrSort.descending(:score),
        SolrSort.descending(:publication_date_sort),
        SolrSort.descending(max_journal_boosted_inventory_score),
        SolrSort.descending(:updated_date_sort)
      )
    end

    # @return [String]
    def browse_sort
      SolrSort.compose(SolrSort.ascending(:encoding_level_sort), SolrSort.descending(:updated_date_sort))
    end

    private

    # Physical holdings are boosted by 2 for Journal/Periodical records
    # @return [String]
    def journal_boosted_physical_inventory_score
      SolrSort.boosted_field_score(field: :physical_holding_count_i, term_boost: PHYSICAL_JOURNAL_BOOST)
    end

    # Electronic inventory are boosted by 3 for Journal/Periodical records.
    # Additionally, electronic inventory get a baseline boost (term_default_weight: 1) even for non-journal formats.
    # This reflects a preference for online availability in default search results
    # @return [String]
    def journal_boosted_electronic_inventory_score
      SolrSort.boosted_field_score(field: :electronic_portfolio_count_i, term_boost: ELECTRONIC_JOURNAL_BOOST,
                                   default_term_boost: ELECTRONIC_INVENTORY_BOOST)
    end

    # Solr function to return whichever boosted inventory score is higher
    # @return [String]
    def max_journal_boosted_inventory_score
      SolrSort.max_score(journal_boosted_physical_inventory_score, journal_boosted_electronic_inventory_score)
    end
  end
end
