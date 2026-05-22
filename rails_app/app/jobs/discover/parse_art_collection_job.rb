# frozen_string_literal: true

module Discover
  # Parse art collection scrape into database
  class ParseArtCollectionJob
    include Sidekiq::Job

    def perform
      file = Faraday.get(Settings.discover.source.art_collection.tsv_path)&.body
      Parser::ArtCollection.import(file: file)
    end
  end
end
