# frozen_string_literal: true

module Catalog
  # Local show tools component for use in a more toolbar-like fashion. Extends BL component (v8.12.2)
  class ShowToolsComponent < Blacklight::Document::ShowToolsComponent
    # Return bookmark action config from array of actions
    # @return [Blacklight::Configuration::ToolConfig]
    def bookmark_action
      actions.find { |action| action.name == :bookmark }
    end

    # Return all non-bookmark actions from array of actions, allowing us to render these in their own drop-down
    # @return [Array<Blacklight::Configuration::ToolConfig>]
    def other_actions
      actions.reject { |action| action.name == :bookmark }
    end
  end
end
