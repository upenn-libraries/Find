# frozen_string_literal: true

# Represents a single document returned from Solr
class SolrDocument
  include Blacklight::Solr::Document
  include LazyMARCParsing

  # Return inventory count from stored fields, whether physical or electronic
  # @return [Integer]
  def inventory_count
    fetch(:physical_holding_count_i) || fetch(:electronic_portfolio_count_i)
  end

  # Parse fill_text_link_ss JSON field
  # @return [Array<Hash>]
  def inventory_link_data
    links_data = fetch :full_text_links_ss, nil
    return nil if links_data.blank?

    JSON.parse(links_data.first, symbolize_names: true)
  end
end
