# frozen_string_literal: true
# Copied from Blacklight version 8.1.0

module Find
  # Our SearchBarComponent that overrides Blacklight::SearchBarComponent in order to accommodate
  # databases search.
  class SearchBarComponent < Blacklight::SearchBarComponent
    # Ensure correct locale scope if handling databases search
    def before_render
      super
      @i18n = { scope: 'search.form.database' } if database_search?
    end

    # @return [Boolean]
    def database_search?
      @params.dig(:f, :format_facet)&.include?(PennMARC::Database::DATABASES_FACET_VALUE) || false
    end
  end
end
