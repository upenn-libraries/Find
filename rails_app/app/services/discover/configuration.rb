# frozen_string_literal: true

module Discover
  class Configuration
    USER_AGENT = 'DiscoverPennFrontend'
    SOURCES = %i[libraries archives museum art_collection].freeze

    module Blacklight
      SOURCES = %i[find finding_aids].freeze
      # Configuration for Find
      module Find
        HOST = 'find.library.upenn.edu'
        PATH = '/catalog.json'
        LINK_TO_SOURCE = true

        TITLE_FIELD = 'title'
        AUTHOR_FIELD = 'creator_ss'
        FORMAT_FIELD = 'format_facet'

        # TODO: all special collections?, like 'Kislak Center for Special Collections' as well
        LIBRARY_VALUES = ['Special Collections'].freeze
        ACCESS_VALUES = [PennMARC::Access::AT_THE_LIBRARY].freeze
        # FORMAT_VALUES = [''].freeze
        # TODO: do these need to be inclusive? if we do exclusive, the first facet will limit the following facets
        QUERY_PARAMS = { 'f[access_facet][]': ACCESS_VALUES,
                         'f[library_facet][]': LIBRARY_VALUES,
                         search_field: 'all_fields' }.freeze
      end

      # Configuration for Finding Aids
      module FindingAids
        # TODO: add finding aids specific config here

        HOST = 'findingaids.library.upenn.edu'
        PATH = '/records.json'
        LINK_TO_SOURCE = true
        TITLE_FIELD = 'title'
        AUTHOR_FIELD = 'creator_ssim'
        FORMAT_FIELD = 'genre_form_ssim'

        RECORD_SOURCE_VALUES = ['upenn'].freeze

        QUERY_PARAMS = { 'f[record_source][]': RECORD_SOURCE_VALUES }.freeze
      end
    end

    module Archives
      BASE_URL = ''
      LINK_TO_SOURCE = true
    end

    module Museum
      BASE_URL = ''
      LINK_TO_SOURCE = true
    end

    module ArtCollection
      BASE_URL = ''
      LINK_TO_SOURCE = false
    end
  end
end
