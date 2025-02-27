# frozen_string_literal: true

module Discover
  module ApiMocks
    module Request
      # Can take either 'find' or 'finding_aids' as the 'source' argument
      # @param source [String] either 'find' or 'finding_aids'
      # @param query [String, Hash] the user query
      # @param response [string] the simulated json response, read in from a fixture
      def stub_blacklight_response(source:, query:, response:)
        host = "Discover::Configuration::Blacklight::#{source.camelize}::HOST".safe_constantize
        path = "Discover::Configuration::Blacklight::#{source.camelize}::PATH".safe_constantize
        stub_request(:get, URI::HTTPS.build(host: host, path: path, query: URI.encode_www_form(query)))
          .to_return_json(status: 200, body: response)
      end

      # @param query [String, Hash] the user query
      # @param response [string] the simulated json response, read in from a fixture
      def stub_pse_response(query:, response:)
        host = Discover::Configuration::PSE::HOST
        path = Discover::Configuration::PSE::PATH
        stub_request(:get, URI::HTTPS.build(host: host, path: path, query: URI.encode_www_form(query)))
          .to_return_json(status: 200, body: response)
      end

      # @param [Hash] query
      # @param [Symbol, Array<Symbol, String>, nil] except
      def stub_all_responses(query:, except: nil)
        except_sources = Array.wrap(except).map(&:to_sym)
        stub_all_blacklight_response(query: query, except: except_sources)
        stub_all_pse_response(query: query, except: except_sources)
      end

      # @param [Hash] query
      # @param [Array<Symbol>] except
      def stub_all_blacklight_response(query:, except:)
        Discover::Configuration::Blacklight::SOURCES.each do |source|
          next if source.in? except

          config = Discover::Configuration.config_for(source: source)
          stub_blacklight_response(source: source.to_s,
                                   query: config::QUERY_PARAMS.merge(query),
                                   response: json_fixture("#{source}_response", :discover))
        end
      end

      # @param [Hash] query
      # @param [Array<Symbol>] except
      def stub_all_pse_response(query:, except:)
        Discover::Configuration::PSE::SOURCES.each do |source|
          next if source.in? except

          config = Discover::Configuration.config_for(source: source)
          stub_pse_response(query: config::QUERY_PARAMS.merge(query),
                            response: json_fixture("#{source}_response", :discover))
        end
      end

      # @param [Hash] query
      def stub_empty_find_response(query:)
        source = 'find'
        config = Discover::Configuration.config_for(source: source)
        stub_blacklight_response(source: source,
                                 query: config::QUERY_PARAMS.merge(query),
                                 response: json_fixture('find_empty_response', :discover))
      end
    end
  end
end
