# frozen_string_literal: true

# Concern for using Blacklight::Ris module to download in RIS format
module RisExport
  extend ActiveSupport::Concern
  include Blacklight::Ris::DocumentFields

  # Defines the fields of RIS format
  module ClassMethods
    def ris_fields
      { TY: proc { to_ris(marc(:format_facet)) }, # format
        TI: proc { marc(:title_show) }, # title
        AU: proc { marc(:creator_authors_list, main_tags_only: true) }, # author
        PY: proc { marc(:date_publication).year }, # publication year
        CY: proc { marc(:production_publication_ris_place_of_pub) }, # place of publication
        PB: proc { marc(:production_publication_ris_publisher) }, # publisher
        ET: proc { marc(:edition_show, with_alternate: false) }, # edition
        SN: proc { marc(:identifier_isbn_show) } } # ISBN
    end
  end

  private

  # Return RIS format in one of these three values: "BOOK", "JOUR", "GEN"
  # @param [Array<String>] formats
  # @return [String]
  def to_ris(formats)
    if formats.include? PennMARC::Format::BOOK
      'BOOK'
    elsif formats.include? PennMARC::Format::JOURNAL_PERIODICAL
      'JOUR'
    else
      'GEN'
    end
  end
end
