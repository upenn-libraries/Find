# frozen_string_literal: true

module Discover
  # Defines configuration values needed to make requests to sources
  class Configuration
    USER_AGENT = 'DiscoverPennFrontend'
    SOURCES = %i[find finding_aids archives museum art_collection].freeze
    RESULT_MAX_COUNT = 3

    module Blacklight
      SOURCES = %i[find finding_aids].freeze
      # Configuration for Find
      module Find
        SOURCE = :find
        HOST = 'find.library.upenn.edu'
        PATH = '/catalog.json'
        LINK_TO_SOURCE = true
        RECORDS = ['data'].freeze
        TOTAL_COUNT = %w[meta pages total_count].freeze
        RESULTS_URL = %w[links self].freeze

        TITLE = %w[attributes title].freeze
        CREATOR = %w[attributes creator_ss attributes value].freeze
        FORMAT = %w[attributes format_facet attributes value].freeze
        LOCATION = %w[attributes library_facet attributes value].freeze
        PUBLICATION = %w[attributes publication_ss attributes value].freeze
        XML = %w[attributes marcxml_marcxml attributes value].freeze
        DESCRIPTION = [nil].freeze
        RECORD_URL = %w[links self].freeze
        COLENDA_LINK_ARK_REGEX = %r{https://colenda.library.upenn.edu/catalog/(.{15})}
        IDENTIFIERS = { isbn: %w[attributes isbn_ss attributes value],
                        issn: %w[attributes issn_ss attributes value],
                        oclc_id: %w[attributes oclc_id_ss attributes value] }.freeze

        # TODO: all special collections?, like 'Kislak Center for Special Collections' as well
        LIBRARY_VALUES = ['Special Collections'].freeze
        ACCESS_VALUES = [PennMARC::Access::AT_THE_LIBRARY].freeze
        # TODO: do these need to be inclusive? if we do exclusive, the first facet will limit the following facets
        QUERY_PARAMS = { 'f[access_facet][]': ACCESS_VALUES,
                         'f[library_facet][]': LIBRARY_VALUES,
                         search_field: 'all_fields' }.freeze
      end

      # Configuration for Finding Aids
      module FindingAids
        SOURCE = :finding_aids
        HOST = 'findingaids.library.upenn.edu'
        PATH = '/records.json'
        LINK_TO_SOURCE = true
        RECORDS = ['data'].freeze
        TOTAL_COUNT = %w[meta pages total_count].freeze
        RESULTS_URL = %w[links self].freeze

        TITLE = %w[attributes title].freeze
        CREATOR = %w[attributes creators_ssim attributes value].freeze
        FORMAT = %w[attributes genre_form_ssim attributes value].freeze
        LOCATION = %w[attributes repository_ssi attributes value].freeze
        PUBLICATION = [nil].freeze
        XML = [nil].freeze
        DESCRIPTION = %w[attributes abstract_scope_contents_tsi attributes value].freeze
        RECORD_URL = %w[links self].freeze
        COLENDA_LINK_ARK_REGEX = %r{https://colenda.library.upenn.edu/catalog/(.{15})}
        IDENTIFIERS = {}.freeze
        RECORD_SOURCE_VALUES = ['upenn'].freeze

        QUERY_PARAMS = { 'f[record_source][]': RECORD_SOURCE_VALUES }.freeze
      end
    end

    module PSE
      SOURCES = %i[museum].freeze

      HOST = 'customsearch.googleapis.com'
      PATH = '/customsearch/v1'
      KEY = Settings.discover.source.google_pse_api_key
      TOTAL_COUNT = %w[searchInformation totalResults].freeze

      module Museum
        SOURCE = :museum
        CX = Settings.discover.source.penn_museum.pse_cx
        QUERY_PARAMS = { cx: CX, key: KEY }.freeze
        LINK_TO_SOURCE = true
        RECORDS = ['items'].freeze
        IDENTIFIERS = {}.freeze
      end
    end

    module Database
      SOURCES = %i[art_collection].freeze
      module ArtCollection
        SOURCE = :art_collection
        MODEL = Discover::ArtWork
        LINK_TO_SOURCE = true
        IDENTIFIERS = {}.freeze
      end
    end

    # @param [String, Symbol] source
    def self.config_for(source:)
      if source.to_sym.in?(Blacklight::SOURCES)
        "Discover::Configuration::Blacklight::#{source.to_s.camelize}".safe_constantize
      elsif source.to_sym.in?(PSE::SOURCES)
        "Discover::Configuration::PSE::#{source.to_s.camelize}".safe_constantize
      elsif source.to_sym.in?(Database::SOURCES)
        "Discover::Configuration::Database::#{source.to_s.camelize}".safe_constantize
      else
        raise Discover::Source::Error, "source #{source} has not been configured"
      end
    end
  end
end
