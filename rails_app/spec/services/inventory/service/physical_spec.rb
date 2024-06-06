# frozen_string_literal: true

describe Inventory::Service::Physical do
  describe '.item' do
    let(:item) { build :item }

    before do
      allow(Alma::BibItem).to receive(:find_one).and_return(item)
    end

    it 'returns a Item' do
      expect(described_class.item(mms_id: '123', holding_id: '456', item_pid: '789'))
        .to be_a Inventory::Service::Item
    end

    it 'raises an ArgumentError if a parameter is missing' do
      expect { described_class.item(mms_id: '123', holding_id: '456', item_pid: nil) }.to raise_error ArgumentError
    end
  end

  describe '.items' do
    let(:item) { build :item }

    it 'returns an array of PennItems when items are present' do
      bib_item_set_double = instance_double(Alma::BibItemSet, items: [item])
      allow(Alma::BibItem).to receive(:find).and_return(bib_item_set_double)
      expect(described_class.items(mms_id: '123', holding_id: '456').first).to be_a Inventory::Service::Item
    end

    it 'returns an array of PennItems when items are not present' do
      bib_item_set_double = instance_double(Alma::BibItemSet, items: [])
      allow(Alma::BibItem).to receive(:find).and_return(bib_item_set_double)
      allow(Alma::BibHolding).to receive(:find_all).and_return('holding' => [{ 'holding_id' => '456' }])
      expect(described_class.items(mms_id: '123', holding_id: '456').first).to be_a Inventory::Service::Item
    end

    it 'returns an empty array when holding data is blank' do
      bib_item_set_double = instance_double(Alma::BibItemSet, items: [])
      allow(Alma::BibItem).to receive(:find).and_return(bib_item_set_double)
      allow(Alma::BibHolding).to receive(:find_all).and_return({})
      expect(described_class.items(mms_id: '123', holding_id: '456')).to eq []
    end

    it 'raises an ArgumentError if a parameter is missing' do
      expect { described_class.items(mms_id: '123', holding_id: nil) }.to raise_error ArgumentError
    end
  end
end
