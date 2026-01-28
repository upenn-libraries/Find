# frozen_string_literal: true

# Local overrides for Blacklight layout helpers
module LayoutHelper
  include Blacklight::LayoutHelperBehavior

  # Set different classes for layout of show page main content section. We want full-width because we're relocating
  # the sidebar tools. Blacklight v9.0 still uses these helpers to render classes
  # @return [String (frozen)]
  def show_content_classes
    'col-lg-12 show-document'
  end

  # Set content for the page title which is read and displayed by Blacklight's base layout
  # @param title [String] the title of the page
  # @param document_title [String, nil] the title of the document
  # @return [String (frozen)]
  def page_title(title, document_title: nil)
    content_for(:page_title) { [title, document_title, application_name].compact.join(' - ') }
  end

  # Overriding method to support using full-width layout for search results.
  # We want container-fluid only for catalog search results, not the home page (catalog#index without
  # search params), advanced search, or account pages. The fi-home class is used for CSS grid targeting.
  # @return [String]
  def container_classes
    if controller_name == 'catalog' && action_name == 'index' && has_search_parameters?
      'container-fluid'
    elsif controller_name == 'catalog' && action_name == 'index'
      'container fi-home'
    else
      'container'
    end
  end
end
