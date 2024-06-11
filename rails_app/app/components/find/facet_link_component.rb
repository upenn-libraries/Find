# frozen_string_literal: true

module Find
  # Renders links to corresponding facet search for record page show values
  class FacetLinkComponent < Blacklight::MetadataFieldComponent
    # @param [String] show_value
    # @return [String]
    def link_to_facet(show_value)
      facet = find_facet(show_value)

      return show_value if facet.blank?

      link_to show_value, search_catalog_path({ "f[#{facet_field}][]": facet })
    end

    private

    # Finds the longest facet that matches the beginning of a given show value
    # @param [String] show_value
    # @return [String, nil]
    def find_facet(show_value)
      facets.find { |facet| show_value.start_with?(facet) }
    end

    # Return facets sorted by length in descending order
    # @return [Array<String>]
    def facets
      @facets ||= @field.document.marc(facet_field).sort_by { |facet| -facet.length }
    end

    # @return [String (frozen)]
    def facet_field
      @facet_field ||= "#{@field.key.split('_').first}_facet"
    end
  end
end
