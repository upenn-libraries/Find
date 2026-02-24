# frozen_string_literal: true

module Discover
  # Load and memoize data used for mapping values
  class Mapper
    class << self
      # @return [Hash, nil]
      def museum_thumbnails
        @museum_thumbnails ||= YAML.safe_load(
          File.read(
            Rails.root.join('app/services/discover/mappings/museum_thumbnails.yml')
          )
        )
      end
    end
  end
end
