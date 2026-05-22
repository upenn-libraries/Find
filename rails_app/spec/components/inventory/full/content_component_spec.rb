# frozen_string_literal: true

describe Inventory::Full::ContentComponent do
  describe '#active?' do
    let(:inventory) { Inventory::List::Response.new(entries: create_list(:physical_entry, 2)) }
    let(:component) { described_class.new(selected_id: selected_id, inventory: inventory) }

    context 'with a selected_id' do
      let(:selected_id) { inventory.entries.first.id }

      it 'returns true for an entry with the same id' do
        expect(component.active?(inventory.entries.first)).to be true
      end

      it 'returns false for an entry with a different id' do
        expect(component.active?(inventory.entries.last)).to be false
      end
    end

    context 'without a selected_id' do
      let(:selected_id) { nil }

      it 'returns true for the first entry' do
        expect(component.active?(inventory.entries.first)).to be true
      end

      it 'returns false for other entries' do
        expect(component.active?(inventory.entries.last)).to be false
      end
    end
  end
end
