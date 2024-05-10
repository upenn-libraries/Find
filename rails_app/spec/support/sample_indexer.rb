# frozen_string_literal: true

# Utilities for indexing sample records as JSON from fixtures for usage in specs
module SampleIndexer
  class << self
    # Index a sample record by filename from fixtures directory
    def index(filename)
      SolrTools.load_data test_collection, json_fixture_file(filename)
    end

    def json_fixture_file(filename)
      Rails.root.join 'spec/fixtures/json', filename
    end

    # Clears test index
    def clear!
      SolrTools.clear_collection test_collection
    end

    def test_collection
      SolrTools.current_collection_name
    end
  end
end
