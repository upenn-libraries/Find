# frozen_string_literal: true

describe Items::Service do
  describe '.item_for' do
    let(:item_data) do
      {
        'bib_data' => {},
        'holding_data' => {},
        'item_data' => {}
      }
    end

    before do
      bib_item_double = instance_double(Alma::BibItem, item: item_data)
      allow(Alma::BibItem).to receive(:find_one).and_return(bib_item_double)
    end

    it 'returns a PennItem' do
      expect(described_class.item_for(mms_id: '123', holding_id: '456', item_pid: '789')).to be_a Items::PennItem
    end

    it 'raises an ArgumentError if a parameter is missing' do
      expect { described_class.item_for(mms_id: '123', holding_id: '456', item_pid: nil) }.to raise_error ArgumentError
    end
  end

  describe '.items_for' do
    let(:item_data) do
      {
        'bib_data' => {},
        'holding_data' => {},
        'item_data' => {}
      }
    end

    it 'returns an array of PennItems when items are present' do
      bib_item_set_double = instance_double(Alma::BibItemSet, items: [Items::PennItem.new(item_data)])
      allow(Alma::BibItem).to receive(:find).and_return(bib_item_set_double)
      expect(described_class.items_for(mms_id: '123', holding_id: '456')).to all(be_a Items::PennItem)
    end

    it 'returns an array of PennItems when items are not present' do
      bib_item_set_double = instance_double(Alma::BibItemSet, items: [])
      allow(Alma::BibItem).to receive(:find).and_return(bib_item_set_double)
      allow(Items::PennItem).to receive(:new).and_return(Items::PennItem.new(item_data))
      expect(described_class.items_for(mms_id: '123', holding_id: '456')).to all(be_a Items::PennItem)
    end

    it 'raises an ArgumentError if a parameter is missing'
  end

  describe '.options_for' do
    it 'returns an array of options'
    context 'when the item is aeon requestable' do
      it 'returns only aeon option'
    end

    context 'when the item is at archives' do
      it 'returns only archives option'
    end

    context 'when the item is checkoutable' do
      it 'returns pickup option'
      it 'returns office option if ils_group is faculty express'
      it 'returns mail option if ils_group is not courtesy borrower'
      it 'returns scan option if item is scannable'
    end
  end
end
