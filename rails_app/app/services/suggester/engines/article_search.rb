# frozen_string_literal: true

module Suggester
  module Engines
    # Suggests an Articles+ search
    class ArticleSearch < Engine
      Registry.register(self)

      BASE_ACTIONS_WEIGHT = 7

      # @param query [String]
      # @return [Boolean]
      def self.suggest?(query)
        query.split.size > 10
      end

      # @return [Suggester::Suggestions::Suggestion]
      def actions
        Suggestions::Suggestion.new(
          entries: [Action.new(label: I18n.t('suggestions.engines.articles_search.label', query: query),
                               url: proxy_url)],
          engine_weight: self.class.actions_weight
        )
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
        Settings.suggester.summon
      end

      # @return [String]
      def proxy_settings
        Settings.suggester.proxy
      end
    end
  end
end
