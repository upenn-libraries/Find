# frozen_string_literal: true

module Discover
  class Configuration
    USER_AGENT = 'DiscoverPennFrontend'
    SOURCES = %i[libraries archives museum art_collection].freeze

    module Libraries
      HOST = 'find.library.upenn.edu'
      PATH = '/catalog.json'
      LINK_TO_SOURCE = true

      # TODO: all special collections?, like 'Kislak Center for Special Collections' as well
      LIBRARY_VALUES = ['Special Collections'].freeze
      ACCESS_VALUES = [PennMARC::Access::AT_THE_LIBRARY].freeze
      # FORMAT_VALUES = [''].freeze
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
