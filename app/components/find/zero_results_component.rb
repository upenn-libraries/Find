# frozen_string_literal: true

module Find
  # Render guidance and alternate routes for zero-results queries
  class ZeroResultsComponent < ViewComponent::Base
    # @param [Blacklight::SearchState] search_state has params, BL config, filters, good stuff
    def initialize(search_state:)
      @search_state = search_state
    end

    # Are filters (facets) present in the params?
    # @return [Boolean]
    def filters_present?
      @search_state.filters.any?
    end

    # The user's query
    # @return [String]
    def query
      @query ||= if @search_state.params[:q].present?
                   @search_state.params[:q]
                 elsif @search_state.params[:clause].present?
                   aggregate_clause_queries
                 end
    end

    # Articles+ link with query
    # @return [String]
    def articles_search_url
      URI::HTTPS.build(host: 'upenn.summon.serialssolutions.com', path: '/search',
                       query: URI.encode_www_form({ ho: 't', 'include.ft.matches': 't', l: 'en', q: query })).to_s
    end

    # BorrowDirect+ link with query
    # @return [String]
    def borrowdirect_search_url
      URI::HTTPS.build(host: 'upenn-borrowdirect.reshare.indexdata.com', path: '/Search/Results',
                       query: URI.encode_www_form({ type: 'AllFields', lookfor: query })).to_s
    end

    # Penn Libraries website search link with query
    # @return [String]
    def website_search_url
      URI::HTTPS.build(host: 'library.upenn.edu', path: '/search-results',
                       query: URI.encode_www_form({ q: '#gsc.tab=0', 'gsc.q': query })).to_s
    end

    # Google Scholar link with query
    # @return [String]
    def scholar_search_url
      URI::HTTPS.build(host: 'scholar.google.com', path: '/scholar',
                       query: URI.encode_www_form({ hl: 'en', q: query })).to_s
    end

    # Penn Libraries "ask" link
    # @return [String]
    def ask_url
      URI::HTTPS.build(host: 'faq.library.upenn.edu', path: '/ask').to_s
    end

    private

    # Attempt to extract query values from an advanced search
    # @return [String]
    def aggregate_clause_queries
      @search_state.params[:clause].values.map { |v| v[:query] }.compact_blank.join(' ')
    end
  end
end
