# frozen_string_literal: true

# Base helper for application views
module ApplicationHelper
  def ris_path(opts = {})
    if controller_name == 'bookmarks'
      bookmarks_path(opts.merge(format: 'ris'))
    else
      solr_document_path(opts.merge(format: 'ris'))
    end
  end

  def render_ris(documents)
    documents.map { |x| x.export_as(:ris) }.compact.join("\n")
  end
end
