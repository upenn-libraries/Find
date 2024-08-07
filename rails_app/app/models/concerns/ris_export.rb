# frozen_string_literal: true

# Concern for using Blacklight::Ris module to download in RIS format
module RisExport
  extend ActiveSupport::Concern
  include Blacklight::Ris::DocumentFields

  # Defines the fields of RIS format
  module ClassMethods
    def ris_fields
      {
        TY: proc { marc(:format_ris) }, # format
        TI: proc { marc(:title_show) }, # title
        AU: proc { marc(:creator_authors_list, main_tags_only: true) }, # author
        PY: proc { marc(:date_publication).year }, # publication year
        CY: proc { marc(:production_publication_ris_place_of_pub) }, # place of publication
        PB: proc { marc(:production_publication_ris_publisher) }, # publisher
        ET: proc { marc(:edition_show, with_alternate: false) }, # edition
        SN: proc { marc(:identifier_isbn_show) } # ISBN
      }
    end
  end
end
