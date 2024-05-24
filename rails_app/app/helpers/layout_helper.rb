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

  # Set content for the page title which is read and displayed by Blacklight's base layout
  # @param title [String] the title of the page
  # @return [String (frozen)]
  def page_title(title, document_title: nil)
    return content_for(:page_title) { "#{title} - #{application_name}" } if document_title.nil?

    content_for(:page_title) { "#{title} - #{document_title} - #{application_name}" }
  end
end
