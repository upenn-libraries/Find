# frozen_string_literal: true

module Suggester
  module Suggestions
    module Solr
      # Provides interface for interacting with Solr suggestion json response
      class Response
        JSON_SUGGEST_FIELD = 'suggest'
        JSON_SUGGESTIONS_FIELD = 'suggestions'
        JSON_TERM_FIELD = 'term'

        # Represent a returned suggestion from the 'title' suggester
        class TitleSuggestion
          attr_reader :term, :weight, :mmsid

          def initialize(solr_term_data)
            @term = solr_term_data['term']
            @weight = solr_term_data['weight']
            @mmsid = solr_term_data['payload']
          end
        end

        # Represent a returned suggestion from the 'notable title' suggester
        class NotableTitleSuggestion < TitleSuggestion
          attr_reader :label

          def initialize(solr_term_data)
            payload = JSON.parse(solr_term_data['payload'])
            @term = solr_term_data['term']
            @weight = solr_term_data['weight']
            @mmsid = payload['id']
            @label = payload['disp']
          end
        end

        # Map suggester names to suggestion objects
        SUGGESTER_MAPPING = {
          title: TitleSuggestion,
          notable_title: NotableTitleSuggestion
        }.freeze

        attr_reader :query, :body

        # @param body [Hash]
        # @param query [Object]
        def initialize(body:, query:)
          @body = body
          @query = query
        end

        # Returns an array of suggestion terms across given suggester in the response - or all terms if no dictionary
        # name is provided.
        # @param dictionary [String, Symbol, nil]
        # @return [Array]
        def terms(dictionary: nil)
          source = dictionary.blank? ? suggestions.values : suggestions[dictionary.to_sym]
          source&.flatten&.collect(&:term) || []
        end

        # Return a hash of suggestion data with keys for each configured suggester and corresponding array of suggestion
        # entities based on the SUGGESTER_MAPPING configuration.
        # @return [Hash]
        def suggestions
          @suggestions ||= begin
            return {} unless body

            body.fetch(JSON_SUGGEST_FIELD, {}).each_with_object({}) do |(suggester, data), hash|
              hash[suggester.to_sym] = build_suggestion_objects(suggester, data)
            end
          end
        end

        private

        # @param suggester [String, Symbol] the name of the suggester
        # @param data [Hash] raw suggestion data from solr response
        # @return [Array<TitleSuggestion, NotableTitleSuggestion>]
        def build_suggestion_objects(suggester, data)
          klass = SUGGESTER_MAPPING[suggester.to_sym]
          raise StandardError, "Unsupported suggester \"#{suggester}\" in Solr response" if klass.blank?

          data.dig(query, JSON_SUGGESTIONS_FIELD).filter_map do |entry|
            klass.new entry
          rescue JSON::ParserError => _e
            Honeybadger.notify "Bad suggester response payload encountered: #{entry}"
            next
          end
        end
      end
    end
  end
end
