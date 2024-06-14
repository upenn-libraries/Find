# frozen_string_literal: true

module Articles
  # Class to initialize the Summon service and retrieve Articles+ results
  #
  # @see https://www.rubydoc.info/gems/summon/2.0.2/Summon Summon gem documentation
  # @see https://developers.exlibrisgroup.com/summon/apis Summon API documentation
  class Search
    attr_reader :client

    delegate :record_count, to: :response

    # Initializes the Summon service and facet manager
    #
    # @param query_term [String] the search query term
    def initialize(query_term:)
      @query_term = query_term
      @client = Summon::Service.new(
        access_id: Settings.additional_results_sources.summon.access_id,
        secret_key: Settings.additional_results_sources.summon.api_key
      )
    end

    # Performs a query of the Summon API and stores the response
    #
    # @see https://developers.exlibrisgroup.com/summon/apis/searchapi/query/parameters
    #   Available query parameters
    # @see https://www.rubydoc.info/gems/summon/2.0.2/Summon/Search
    #   Documentation for the Search class (Summon gem)
    #
    # @return [Summon::Search, nil] successful search response from the Summon API,
    #   or no response if there was an error
    # rubocop:disable Metrics/MethodLength
    def response
      @response ||= client.search({ 's.q' => @query_term,
                                    's.include.ft.matches' => 't',
                                    's.ho' => 't',
                                    's.role' => 'authenticated',
                                    's.ps' => 3,
                                    's.hl' => 'f',
                                    's.ff' => 'ContentType,or,1,6' })
    rescue Summon::Transport::TransportError => e
      Honeybadger.notify(e)
      handle_error(e)
      nil
    end

    # rubocop:enable Metrics/MethodLength

    # @return [Array<Articles::Document>, nil] documents returned from the search
    def documents
      return unless success?

      @documents ||= response.documents.map do |document|
        Articles::Document.new(document)
      end
    end

    # @return [String] query string from the initial search response
    def query_string
      response.query.query_string
    end

    # @return [Boolean] whether or not the search connected successfully and
    #   returned documents
    def success?
      response.present? && response.respond_to?(:documents)
    end

    # @return [Articles::FacetManager, nil] the facet manager for the search
    def facet_manager
      # If there was an error connecting to the Summon API or no documents were
      # found, don't try to build the facet counts
      return unless success?

      @facet_manager ||= Articles::FacetManager.new(
        facets: response.facets,
        query_string: query_string
      )
    end

    class << self
      # @param query [String] the search query string from which to generate the URL
      # @return [String] URL linking to the results of the search on Articles+
      def summon_url(query: query_string)
        URI::HTTPS.build(host: Settings.additional_results_sources.summon.base_url,
                         path: '/search',
                         query: query).to_s
      end
    end

    private

    # Prints any Summon connection errors to the rails logger instead of raising
    # an exception. This allows the Additional Results component's Turbo frame
    # to display "No Articles+ results" instead of "Content missing"
    #
    # @param error [Summon::Transport::TransportError] the error to handle
    def handle_error(error)
      if error.is_a? Summon::Transport::AuthorizationError
        Rails.logger.error 'Could not connect to the Summon service. Check your access id and secret key.'
      else
        Rails.logger.error error.message
      end
    end
  end
end
