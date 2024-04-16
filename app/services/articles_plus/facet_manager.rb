# frozen_string_literal: true

module ArticlesPlus
  # Manages facets and their document counts as returned from the Summon API
  #
  # @see https://www.rubydoc.info/gems/summon/2.0.2/Summon/Facet
  #   Facet class documentation (Summon gem)
  # @see https://www.rubydoc.info/gems/summon/2.0.2/Summon/FacetCount
  #   FacetCount class documentation (Summon gem)
  # @see https://developers.exlibrisgroup.com/summon/apis/searchapi/response/facetfields
  #   facetFields documentation (Summon API) with further details on the fields
  #   available to Facet and FacetCount
  class FacetManager
    attr_reader :counts

    # @param search [ArticlesPlus::Search] an Articles+ search service
    def initialize(search:)
      @search = search
      # If there was an error connecting to the Summon API or no documents were
      # found, don't try to build the facet counts
      return unless @search.success?

      @facets = @search.response.facets
      @counts = map_facet_counts
    end

    private

    # Maps the document counts for each facet to a hash, allowing for easy reference
    # to document counts by facet display name
    #
    # @return [Hash, nil] facet count data by facet display name (label, count, and url for each)
    def map_facet_counts
      @facets&.each_with_object({}) do |facet, counts|
        counts[facet.display_name] = facet.counts.map do |count|
          {
            label: count.value,
            doc_count: count.count,
            url: @search.summon_url(query: facet_count_query_string(facet.display_name, count.value))
          }
        end
      end
    end

    # Generates a query string to filter Articles+ search results by the
    # specified facet and count
    #
    # @param facet_display_name [String]
    # @param facet_count_label [String]
    # @return [String]
    def facet_count_query_string(facet_display_name, facet_count_label)
      query_string = @search.query_string
      query_string += "&s.fvf=#{facet_display_name},#{CGI.escape(facet_count_label)},f"

      query_string.encode('utf-8')
    end
  end
end
