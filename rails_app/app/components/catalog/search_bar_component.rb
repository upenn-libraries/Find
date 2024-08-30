# frozen_string_literal: true

module Catalog
  # Local version of Blacklight v8.3.0@69373f202 SearchBarComponent, overridden in order to customize template
  class SearchBarComponent < Blacklight::Component
    renders_one :append
    renders_one :prepend
    renders_one :search_button
    renders_many :before_input_groups

    # rubocop:disable Metrics/ParameterLists Metrics/MethodLength
    def initialize(
      url:, params:,
      advanced_search_url: nil,
      classes: ['search-query-form'], prefix: nil,
      method: 'GET', q: nil, query_param: :q,
      search_field: nil, autocomplete_path: nil,
      autofocus: nil, i18n: { scope: 'blacklight.search.form' },
      form_options: {}
    )
      @url = url
      @advanced_search_url = advanced_search_url
      @q = q || params[:q]
      @query_param = query_param
      @search_field = search_field || params[:search_field]
      @params = params.except(:q, :search_field, :utf8, :page)
      @prefix = prefix
      @classes = classes
      @method = method
      @autocomplete_path = autocomplete_path
      @autofocus = autofocus
      @i18n = i18n
      @form_options = form_options
    end
    # rubocop:enable Metrics/ParameterLists Metrics/MethodLength

    def autocomplete_path
      return nil unless blacklight_config.autocomplete_enabled

      @autocomplete_path
    end

    def autofocus
      if @autofocus.nil?
        blacklight_config.enable_search_bar_autofocus &&
          controller.is_a?(Blacklight::Catalog) &&
          controller.action_name == 'index' &&
          !controller.has_search_parameters?
      else
        @autofocus
      end
    end

    def search_fields
      @search_fields ||= blacklight_config.search_fields.values
                                          .select { |field_def| helpers.should_render_field?(field_def) }
                                          .collect do |field_def|
        [helpers.label_for_search_field(field_def.key),
         field_def.key]
      end
    end

    def advanced_search_enabled?
      blacklight_config.advanced_search.enabled
    end

    private

    def blacklight_config
      helpers.blacklight_config
    end

    def scoped_t(key, **args)
      t(key, default: t(key, scope: 'blacklight.search.form'), **@i18n, **args)
    end
  end
end
