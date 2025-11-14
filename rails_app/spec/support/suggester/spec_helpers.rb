# frozen_string_literal: true

module Suggester
  module SpecHelpers
    # @return [Class]
    def mock_engine_class(actions: [], completions: [], success: false)
      Class.new(Suggester::Engines::Engine) do
        define_method(:actions) { actions }
        define_method(:completions) { completions }
        define_method(:success?) { success }
      end
    end

    # @return [Class]
    def mock_engine_with_actions
      mock_engine_class(actions: Suggester::Suggestions::Suggestion.new(entries: [{
                                                                          label: 'Search titles for "query"',
                                                                          url: 'https://find.library.upenn.edu/?field=title&q=query'
                                                                        }]), success: true)
    end

    # @return [Class]
    def mock_engine_with_completions
      mock_engine_class(completions: Suggester::Suggestions::Suggestion.new(entries: ['query syntax',
                                                                                      'query language',
                                                                                      'query errors',
                                                                                      'adversarial queries']),
                        success: true)
    end

    # @param query_params [Hash]
    # @param response_body [Hash]
    # @param url [String] solr url
    # @return [WebMock::RequestStub]
    def stub_solr_suggestions_request(query_params:, response_body:, status: 200,
                                      url: Settings.suggester.digital_catalog.solr.url)
      uri = URI.parse(url)
      stub_request(:get, "#{uri.origin}#{uri.path}").with(query: query_params)
                                                    .with(headers: { 'Accept'=>'*/*' })
                                                    .to_return_json(status: status, body: response_body)
    end

    # @param [String] filename
    # @return [String]
    def json_fixture(filename, directory = nil)
      filename = "#{filename}.json" unless filename.ends_with?('.json')
      dirs = ['json', directory.to_s, filename].compact_blank
      File.read(File.join(fixture_paths, dirs))
    end

    # Helper to mimic a response from the Suggester Service
    # @param status [Symbol]
    # @param actions [Array]
    # @param completions [Array]
    # @return [Hash]
    def suggester_response(status: :success, actions: [], completions: [])
      { status: status,
        data: { params: {}, context: {},
                suggestions: { actions: actions, completions: completions } } }
    end
  end
end
