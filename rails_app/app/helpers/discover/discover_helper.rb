# frozen_string_literal: true

module Discover
  # Helper for Discover Penn functionality, mostly for the application layout
  module DiscoverHelper
    # Get the page's HTML title - query term if present, otherwise page name if defined, otherwise just site name
    #
    # @return [String, nil]
    def render_discover_html_title
      if discover_query_params?
        discover_search_results_html_title
      elsif content_for?(:html_title)
        content_for(:html_title)
      else
        t('discover.site_name')
      end
    end

    # Set content for the html page title on a Discover Penn search results page
    #
    # @return [String (frozen), nil]
    def discover_search_results_html_title
      return unless discover_query_params?

      [discover_query, t('discover.site_name')].compact.join(' - ')
    end

    # Set content for the html page title on a Discover Penn page
    #
    # @param title [String, nil] the title of the page
    # @return [String (frozen), nil]
    def discover_html_title(title = nil)
      content_for(:html_title) { [title, t('discover.site_name')].compact.join(' - ') }
    end

    # Get the search term
    #
    # @return [String]
    def discover_query
      params[:q]
    end

    # Check if search params are present
    #
    # @return [Boolean]
    def discover_query_params?
      discover_query.present?
    end
  end
end
