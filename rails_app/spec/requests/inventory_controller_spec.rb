# frozen_string_literal: true

describe 'Inventory requests' do
  include_context 'with electronic journal record with 4 electronic entries'

  let(:mms_id) { electronic_journal_bib }
  let(:entries) { electronic_journal_entries }

  context 'when retrieving brief inventory' do
    before { get brief_inventory_path(mms_id) }

    it 'returns expected entries' do
      expect(response.body).to include entries.first.description
    end
  end

  context 'when retrieving electronic detail' do
    before { get electronic_detail_inventory_path(mms_id, entries.second.id, entries.second.collection_id) }

    it 'returns expected note' do
      expect(response.body).to include 'In this database, you may need to navigate to view your article.'
    end
  end
end
