# frozen_string_literal: true

# Represents a single document returned from Solr
class SolrDocument
  include Blacklight::Solr::Document
  include MARCParsing
  include MARCExport

  # @return [Inventory::Response]
  def full_inventory
    Inventory::List.full self
  end

  # @return [Inventory::Response]
  def brief_inventory
    Inventory::List.brief self
  end

  # Return the sum of physical and electronic inventory entries from stored fields
  # @return [Integer]
  def inventory_count
    fetch(:physical_holding_count_i) + fetch(:electronic_portfolio_count_i)
  end

  # Parse fill_text_link_ss JSON field to return resource links from MARC 856
  # @return [Array]
  def marc_resource_links
    links_data = fetch :full_text_links_ss, nil
    @marc_resource_links ||= if links_data.blank?
                               []
                             else
                               JSON.parse(links_data.first, symbolize_names: true)
                             end
  end

  def export_as_mla_citation_txt
    mla_citation_txt
  end

  def export_as_apa_citation_txt
    apa_citation_txt
  end

  def export_as_chicago_citation_txt
    chicago_citation_txt
  end
end
