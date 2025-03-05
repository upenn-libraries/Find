# frozen_string_literal: true

module Discover
  # Parse art collection scrape into database
  class ParseArtCollectionJob
    include Sidekiq::Job

    def perform
      Parser::ArtCollection.import
    end
  end
end
