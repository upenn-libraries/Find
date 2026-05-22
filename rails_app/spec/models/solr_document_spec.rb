# frozen_string_literal: true

require 'rails_helper'

describe SolrDocument do
  it_behaves_like 'MARCParsing'
  it_behaves_like 'CitationExport'
  it_behaves_like 'RisExport'
  it_behaves_like 'OpenUrlExport'
end
