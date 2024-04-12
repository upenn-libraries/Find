# frozen_string_literal: true

module Items
  # TODO: fill this out with Franklin PennItem stuff
  # adds necessary functionality to determine item checkout status for rendering circulation options
  class PennItem < Alma::BibItem
    def checkoutable?
      false
    end

    def select_label
      [[description, physical_material_type['desc'], public_note, library_name]
        .compact_blank.join(' - '), item_data['pid']]
    end
  end
end
