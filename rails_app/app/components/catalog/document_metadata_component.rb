# frozen_string_literal: true

module Catalog
  # Override DocumentMetadataComponent from Blacklight 9.0.0.beta8 to render our custom MetadataFieldLayoutComponent.
  class DocumentMetadataComponent < Blacklight::DocumentMetadataComponent
    def initialize(fields: [], **)
      super

      @field_layout = Catalog::MetadataFieldLayoutComponent
    end
  end
end
