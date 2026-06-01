# frozen_string_literal: true

describe Inventory::Brief::EntryComponent do
  describe '#summary_fields' do
    subject(:fields) { described_class.new(entry: entry).summary_fields }

    context 'with a physical entry' do
      let(:entry) { create(:physical_entry) }

      it 'returns status, location, and call_number in that order' do
        expect(fields.pluck(:key)).to eq %i[status location call_number]
      end

      it 'maps status to human_readable_status' do
        expect(fields.find { |f| f[:key] == :status }[:value]).to eq entry.human_readable_status
      end

      it 'maps location to human_readable_location' do
        expect(fields.find { |f| f[:key] == :location }[:value]).to eq entry.human_readable_location
      end

      it 'maps call_number to description' do
        expect(fields.find { |f| f[:key] == :call_number }[:value]).to eq entry.description
      end
    end

    context 'with an electronic entry that has coverage' do
      let(:entry) { create(:electronic_entry) }

      it 'returns status, collection, and coverage in that order' do
        expect(fields.pluck(:key)).to eq %i[status collection coverage]
      end
    end

    context 'with an electronic entry that has no coverage' do
      let(:entry) { create(:electronic_entry, coverage_statement: nil) }

      it 'prunes blank fields and returns only status and collection' do
        expect(fields.pluck(:key)).to eq %i[status collection]
      end
    end

    context 'with a resource_link entry' do
      let(:entry) { create(:resource_link_entry) }

      it 'returns status and description' do
        expect(fields.pluck(:key)).to eq %i[status description]
      end
    end
  end

  describe '#note_content' do
    subject(:note) { described_class.new(entry: entry).note_content }

    context 'with an electronic entry that has a public note' do
      let(:entry) { create(:electronic_entry, public_note: 'Off-campus access requires PennKey.') }

      it 'returns the note value' do
        expect(note.to_s).to include 'PennKey'
      end
    end

    context 'with an electronic entry that has no public note' do
      let(:entry) { create(:electronic_entry, public_note: nil) }

      it 'returns nil' do
        expect(note).to be_nil
      end
    end

    context 'with a physical entry' do
      let(:entry) { create(:physical_entry) }

      it 'returns nil' do
        expect(note).to be_nil
      end
    end
  end
end
