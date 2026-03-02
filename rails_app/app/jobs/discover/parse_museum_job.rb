# frozen_string_literal: true

module Discover
  # Parse art collection scrape into database
  class ParseMuseumJob
    include Sidekiq::Job

    def perform
      harvest_response = Harvester::PennMuseum.new.harvest do |file|
        Parser::PennMuseum.import(file: file)
        Parser::PennMuseum.delete_missing(file: file)
      end
      harvest.update_from_response_headers! harvest_response.headers
    end

    private

    # @return [Discover::Harvest]
    def harvest
      Harvest.find_or_initialize_by(source: 'penn_museum')
    end
  end
end
