# frozen_string_literal: true

module Find
  # Local show tools component for use in a more toolbar-like fashion
  class ShowToolsComponent < Blacklight::Document::ShowToolsComponent
    # @return [Blacklight::Configuration::ToolConfig]
    def bookmark_action
      actions.find { |action| action.name == :bookmark }
    end

    # @return [Array<Blacklight::Configuration::ToolConfig>]
    def other_actions
      actions.reject { |action| action.name == :bookmark }
    end
  end
end
