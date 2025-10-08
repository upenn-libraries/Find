# frozen_string_literal: true

module Catalog
  # Renders links to corresponding facet search for record page show values. This is for use when the displayed value
  # and the facet value come from different stored fields or parser methods. If the field we want to link is identical,
  # then using Blacklight's `link_to_facet` configuration is the preferred solution.
  class FacetLinkComponent < Blacklight::MetadataFieldComponent
    attr_reader :matches, :limit

    def initialize(field:, layout: nil, show: nil, view_type: nil)
      super
      @matches = []
      @limit = @field.field_config.limit
    end

    # If a limit value is set in the field configuration, this will return a limited set of the displayed fields based
    # on the limit value in the field configuration.
    # @return [Array]
    def limited_field_values
      return @field.values unless truncate_values_list?

      @field.values.first(limit) || []
    end

    # @param [String] show_value
    # @return [String]
    def link_to_facet(show_value)
      facet = facet_mapping[show_value]

      return show_value if facet.blank?

      link_to show_value, search_catalog_path({ "f[#{facet_field}][]": facet })
    end

    # Indicate whether the displayed values will be truncated given the field configuration limit value and the
    # length of the values for display. This could be useful in rendering a "See More..." type interface element.
    # @return [Boolean]
    def truncate_values_list?
      @truncate_values_list ||= limit.present? && (limit < @field.values.length)
    end

    private

    # Finds the longest remaining facet that matches the beginning of a given show value. We use the facet mapping
    # hash and add each new match to our matches array. This prevents show values without a corresponding facet from
    # incorrectly matching another shorter facet.
    # @param [String] show_value
    # @return [String, nil]
    def find_facet(show_value)
      facet = sorted_facets.find { |f| show_value.start_with?(f) && matches.exclude?(f) }

      matches << facet if facet.present?

      facet
    end

    # Returns a hash mapping each show value with its corresponding facet. Some show fields are configured to use their
    # own pennmarc facet map methods. Otherwise, we build the facet map using the sorted show values array to match
    # shorter show values first to prevent false positives.
    # @return [Enumerator, Hash]
    def facet_mapping
      @facet_mapping ||= if @field.field_config.facet_map
                           @field.document.marc(@field.field_config.facet_map)
                         else
                           sorted_show_values.index_with { |show_value| find_facet(show_value) }
                         end
    end

    # Facets sorted by length in descending order
    # @return [Array<String>]
    def sorted_facets
      @sorted_facets ||= @field.document.marc(facet_field).sort_by { |facet| -facet.length }
    end

    # Retrieve corresponding facet field from field config or by combining helper name + '_facet'.
    # @return [String (frozen)]
    def facet_field
      @facet_field ||= @field.field_config.facet_target || "#{@field.key.split('_').first}_facet"
    end

    # Show values sorted by length in ascending order. We use this sorted array when matching
    # show values to facets.
    # @return [Array<String>]
    def sorted_show_values
      @sorted_show_values ||= @field.values.sort_by(&:length)
    end
  end
end
