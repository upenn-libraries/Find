# frozen_string_literal: true

module ArticlesPlus
  # Class to initialize the Summon service and retrieve Articles+ results
  #
  # @see https://www.rubydoc.info/gems/summon/2.0.2/Summon Summon gem documentation
  # @see https://developers.exlibrisgroup.com/summon/apis Summon API documentation
  class Search
    delegate :record_count, to: :response

    # Initializes the Summon service and facet manager
    #
    # @param query_term [String] the search query term
    def initialize(query_term:)
      @query_term = query_term
      @client = Summon::Service.new(
        access_id: summon_credentials[:id],
        secret_key: summon_credentials[:key]
      )
      @facet_manager = ArticlesPlus::FacetManager.new(search: self)
    end

    # Performs a query of the Summon API and stores the response
    #
    # @see https://developers.exlibrisgroup.com/summon/apis/searchapi/query/parameters
    #   Available query parameters
    # @see https://www.rubydoc.info/gems/summon/2.0.2/Summon/Search
    #   Documentation for the Search class (Summon gem)
    #
    # @return [Summon::Search] search response from the Summon API
    def response
      @response ||= @client.search({
                                     's.q' => @query_term,
                                     's.ho' => 't',
                                     's.ps' => 3,
                                     's.secure' => 't',
                                     's.ff' => 'ContentType,or'
                                   })
    rescue Summon::Transport::TransportError => e
      handle_error(e)
    end

    # @return [Array<ArticlesPlus::Document>, nil] documents returned from the search
    def documents
      return unless success?

      response.documents.map do |document|
        ArticlesPlus::Document.new(document)
      end
    end

    # @param query [String] the search query string from which to generate the URL
    # @return [String] URL linking to the results of the search on Articles+
    def summon_url(query: query_string)
      URI::HTTPS.build(host: Settings.summon.base_url,
                       path: '/search',
                       query: query).to_s
    end

    # @return [String] query string from the initial search response
    def query_string
      response.query.query_string
    end

    # @return [Hash, nil] facet counts by facet display name
    def facet_counts
      @facet_manager&.counts
    end

    # @return [Boolean] whether or not the search connected successfully and
    #   returned documents
    def success?
      response.present? && response.respond_to?(:documents)
    end

    private

    # @return [Hash] credentials for accessing the Summon API
    def summon_credentials
      {
        id: Settings.summon.access_id,
        key: Rails.application.credentials[:summon_api_key]
      }
    end

    # Prints any Summon connection errors to the rails logger instead of raising
    # an exception. This allows the Additional Results component's Turbo frame
    # to display "No Articles+ results" instead of "Content missing"
    #
    # @param error [Summon::Transport::TransportError] the error to handle
    def handle_error(error)
      # @todo Notify with Honeybadger
      if error.is_a? Summon::Transport::AuthorizationError
        Rails.logger.error 'Could not connect to the Summon service. Check your access id and secret key.'
      else
        Rails.logger.error error.message
      end
    end
  end
end
