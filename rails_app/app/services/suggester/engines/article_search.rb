# frozen_string_literal: true

module Suggester
  module Engines
    # Suggests an Articles+ search
    class ArticleSearch < SuggestionEngine
      EngineRegistry.register(self)

      # @return [Integer]
      def self.weight
        7
      end

      # @param query [String]
      # @return [Boolean]
      def self.suggest?(query)
        query.split.size > 10
      end

      # @return [Suggester::Suggestion]
      def actions
        Suggestion.new(entries: [{ label: I18n.t('suggestions.engines.articles_search.label', query: query),
                                   url: proxy_url }], engine_weight: self.class.weight)
      end

      private

      # @return [String]
      def summon_url
        URI::HTTPS.build(host: summon_settings.host, path: summon_settings.path, query: { "s.q": query }.to_query).to_s
      end

      # @return [String]
      def proxy_url
        URI::HTTPS.build(host: proxy_settings.host, path: proxy_settings.path, query: "url=#{summon_url}").to_s
      end

      # @return [String]
      def summon_settings
        Settings.suggestions.summon
      end

      # @return [String]
      def proxy_settings
        Settings.suggestions.proxy
      end
    end
  end
end
