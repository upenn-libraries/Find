# frozen_string_literal: true

module Articles
  module ApiMocks
    module Search
      def stub_summon_search_success(query:, fixture:)
        stub_request(:get, summon_api_url(query))
          .to_return(status: 200,
                     body: articles_file_fixture(fixture),
                     headers: { 'Content-Type': 'application/json' })
      end

      def stub_summon_search_failure(query:)
        stub_request(:get, summon_api_url(query))
          .to_return(status: 401)
      end

      def summon_api_url(query)
        %r{http://api\.summon\.serialssolutions\.com/2\.0\.0.*#{query}.*}
      end

      def articles_file_fixture(filename)
        Rails.root.join 'spec/fixtures/json/articles', filename
      end
    end
  end
end
