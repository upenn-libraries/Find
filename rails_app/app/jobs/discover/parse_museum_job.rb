# frozen_string_literal: true

module Discover
  # Parse art collection scrape into database
  class ParseMuseumJob
    include Sidekiq::Job

    def perform
      Harvester::PennMuseum.new.harvest do |file|
        Parser::PennMuseum.import(file: file)
      end
    end
  end
end
