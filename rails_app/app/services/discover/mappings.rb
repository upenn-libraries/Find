# frozen_string_literal: true

module Discover
  # Load and memoize data used for mapping values
  class Mappings
    class << self
      # @return [Hash, nil]
      def museum_thumbnails
        @museum_thumbnails ||= YAML.safe_load(
          File.read(Rails.root.join('lib/discover/museum_thumbnails.yml'))
        )
      end
    end
  end
end
