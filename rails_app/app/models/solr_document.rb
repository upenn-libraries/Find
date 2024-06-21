# frozen_string_literal: true

# Represents a single document returned from Solr
class SolrDocument
  include Blacklight::Solr::Document
  include MARCParsing
  include MARCExport
  include RisFields
  use_extension(MARCExport)

  # @return [Inventory::Response]
  def full_inventory
    Inventory::Service.full self
  end

  # @return [Inventory::Response]
  def brief_inventory
    Inventory::Service.brief self
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

  # define the fields for RIS format
  ris_field_mappings.merge!(
    # Procs are evaluated in context of SolrDocument instance
    TY: proc { marc(:format_facet) }, # format
    TI: proc { marc(:title_show) }, # title
    AU: proc { marc(:creator_authors_list, main_tags_only: true) }, # author
    PY: proc { marc(:date_publication).year }, # publication year
    CY: proc { marc(:production_publication_ris_place_of_pub) }, # place of publication
    PB: proc { marc(:production_publication_ris_publisher) }, # publisher
    ET: proc { marc(:edition_show, with_alternate: false) },  # edition
    SN: proc { marc(:identifier_isbn_show) }  # ISBN
  )
end
