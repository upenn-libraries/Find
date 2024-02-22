# frozen_string_literal: true

# Local overrides for Blacklight layout helpers
module LayoutHelper
  include Blacklight::LayoutHelperBehavior

  # Set different classes for layout of show page main content section. We want full-width because we're relocating
  # the sidebar tools. Blacklight 8.1.0 still uses these helpers to render classes
  # @return [String (frozen)]
  def show_content_classes
    'col-lg-12 show-document'
  end
end
