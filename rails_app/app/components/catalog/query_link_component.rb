# frozen_string_literal: true

module Catalog
  # Copied from Blacklight v9.0
  #
  # Renders links to fielded searches for record page show values
  class QueryLinkComponent < Blacklight::MetadataFieldComponent
    # Generates a link to perform a fielded search based on the provided show value.
    # If a corresponding query is found, it returns a link. Otherwise, it returns the show_value as plain text.
    #
    # @param show_value [String] The value to display and potentially link.
    # @return [String] A hyperlink or the unlinked show_value.
    def link_to_query(show_value)
      query = query(show_value)
      return show_value if query.blank?

      link_to show_value, search_catalog_path(query_params(query))
    end

    private

    # Determines the appropriate query to use for the provided show value.
    # If a query map is not configured, it returns the show value itself. Otherwise it returns the query value found in
    # the query map.
    #
    # @param show_value [String] The value from the record to be used in the search query.
    # @return [String, nil] The query string wrapped in quotes, or nil if no query is found.
    def query(show_value)
      return "\"#{show_value}\"" unless query_map

      mapped_query = query_map[show_value]

      return unless mapped_query

      "\"#{mapped_query}\""
    end

    # Field we want to search over
    # @return [Symbol]
    def search_target
      @search_target ||= @field.field_config.search_target
    end

    # Clause index associated with search field
    # @return [Integer]
    def clause_index
      @clause_index ||=  begin
        fields = @field.view_context.blacklight_config.search_fields.select { |_k, v| v.include_in_advanced_search }
        fields.keys.find_index(search_target.to_s)
      end
    end

    # Params for a fielded search
    # @param query [String]
    # @return [Hash{Symbol->Hash{Symbol->Hash{Symbol->String}}}]
    def query_params(query)
      {
        clause: {
          "#{clause_index}": {
            field: search_target,
            query: query
          }
        }
      }
    end

    # Returns a hash mapping each show value to its corresponding query, or nil if no such query map is configured
    # @return [Hash, nil]
    def query_map
      @query_map ||= @field.document.marc(@field.field_config.query_map) if @field.field_config.query_map
    end
  end
end
