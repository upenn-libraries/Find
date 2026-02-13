# frozen_string_literal: true

module Discover
  # Parse art collection scrape into database
  class ParseMuseumJob
    include Sidekiq::Job

    def perform
      Parser::PennMuseum.import
    end
  end
end
