# frozen_string_literal: true

require 'system_helper'

describe 'Catalog show page with an Electronic record' do
  include_context 'with electronic journal record with 4 electronic entries'
  include_context 'with empty hathi response'

  let(:mms_id) { electronic_journal_bib }
  let(:entries) { electronic_journal_entries }

  include_examples 'core show page features'

  context 'when additional details/notes can be retrieved from Alma' do
    before do
      visit solr_document_path(mms_id)
      click_button entries.second.description # second entry has additional details
    end

    it 'displays additional details/notes with allowable markup' do
      within('#inventory-1') do
        expect(page).to have_selector '.inventory-item__notes',
                                      text: 'In this database, you may need to navigate to view your article.'
        expect(page).not_to have_text '<strong>'
      end
    end
  end
end
