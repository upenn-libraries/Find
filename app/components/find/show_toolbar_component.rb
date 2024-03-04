# frozen_string_literal: true

module Find
  # Application document/result/show page toolbar. Home for result navigation and document tools.
  class ShowToolbarComponent < Blacklight::Component
    attr_accessor :applied_params_component, :item_pagination_component, :bookmark_component, :actions_component

    def initialize(document:, blacklight_config:, search_context:, search_session:, params:)
      @document = document
      @blacklight_config = blacklight_config
      # TODO: these are configurable via configure_blacklight...
      @applied_params_component = Blacklight::SearchContext::ServerAppliedParamsComponent.new
      @item_pagination_component = Blacklight::SearchContext::ServerItemPaginationComponent.new(
        search_context: search_context, search_session: search_session, current_document: document
      )
      doc_actions = []
      bookmark_config = nil
      blacklight_config.show.document_actions.each do |k, v|
        if k == :bookmark
          bookmark_config = v
        else
          doc_actions << v
        end
      end
      @bookmark_component = bookmark_config ? Blacklight::Document::BookmarkComponent.new(document: document, action: bookmark_config) : nil
      @actions_component = doc_actions.any? ? Blacklight::Document::ActionsComponent.new(
        document: document, actions: doc_actions, classes: '', url_opts: Blacklight::Parameters.sanitize(params.to_unsafe_h)
      ) : []
    end
  end
end
