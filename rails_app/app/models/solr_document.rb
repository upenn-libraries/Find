# frozen_string_literal: true

# Represents a single document returned from Solr
class SolrDocument
  include Blacklight::Solr::Document
  include MARCParsing
  include Blacklight::Ris::DocumentFields
  use_extension(Blacklight::Ris::DocumentExport)

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

  # define the RIS fields
  ris_field_mappings.merge!(
    TY: proc { marc(:format_facet).map(&:upcase) }, # format
    TI: proc { marc(:title_show) }, # title
    AU: proc { marc(:creator_authors_list, main_tags_only: true) }, # author
    PY: proc { marc(:date_publication).year }, # publication year
    CY: proc { marc(:production_publication_ris_place_of_pub) }, # place of publication
    PB: proc { marc(:production_publication_ris_publisher) }, # publisher
    ET: proc { marc(:edition_show, with_alternate: false) }, # edition
    SN: proc { marc(:identifier_isbn_show) } # ISBN
  )
end
