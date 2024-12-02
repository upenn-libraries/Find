# frozen_string_literal: true

# Represents a single document returned from Solr
class SolrDocument
  include Blacklight::Solr::Document
  include MARCParsing
  include CitationExport
  include RisExport

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

  # Return mms_id of host record if document is representing a boundwith.
  # @return [String, nil]
  def host_record_id
    fetch(:host_record_id_ss, []).first
  end

  # Get alternate title (field is not indexed yet - should it be?)
  # @return [String, nil]
  def alternate_title
    marc(:title_alternate_show)
  end

  # Get detailed title with inclusive dates (field is not indexed yet - should it be?)
  # @return [String, nil]
  def detailed_title
    marc(:title_detailed_show)
  end

  # String date and time that the record was last indexed
  # @return [String, nil]
  def last_indexed
    fetch(:indexed_date_s, nil)
  end

  # Identifier to be used by Hathi API service to get Hathi link
  # @return [Hash]
  def identifier_map
    types = %w[oclc_id isbn issn]
    types.each_with_object({}) do |type, ids|
      value = fetch(:"#{type}_ss", []).first
      ids[:"#{type.sub('_id', '')}"] = value.gsub(/[^0-9-]/, '') if value
    end
  end
end
