# frozen_string_literal: true

module Catalog
  # Overriding component from Blacklight v9.0.0.beta8 to remove styling from dd tags.
  class MetadataFieldLayoutComponent < Blacklight::MetadataFieldLayoutComponent
    def initialize(field:, value_tag: 'dd', label_class: nil, value_class: nil, offset_class: nil)
      super
    end
  end
end
