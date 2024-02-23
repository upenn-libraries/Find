# frozen_string_literal: true

require 'system_helper'

describe 'Catalog Show Page' do
  let(:bib) { '9913203433503681' }

  before do
    SampleIndexer.index 'print_monograph.json'
    visit librarian_view_solr_document_path bib
  end

  after { SampleIndexer.clear! }

  it 'renders title' do
    expect(page).to have_content 'Librarian View'
  end

  it 'renders expected fields' do
    expect(page).to have_selector '.field', text: /^LEADER/
    expect(page).to have_selector '.field', text: /^001/
  end
end
