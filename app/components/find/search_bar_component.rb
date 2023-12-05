# frozen_string_literal: true

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
      @params.dig(:f, :format_facet)&.include?('Database & Article Index') || false
    end
  end
end
