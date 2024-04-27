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
      expect(described_class.items(mms_id: '123', holding_id: '456')).to all(be_a Inventory::Service::Item)
    end

    it 'returns an array of PennItems when items are not present' do
      bib_item_set_double = instance_double(Alma::BibItemSet, items: [])
      allow(Alma::BibItem).to receive(:find).and_return(bib_item_set_double)
      allow(Alma::BibHolding).to receive(:find_all).and_return('holding' => [{ 'holding_id' => '456' }])
      expect(described_class.items(mms_id: '123', holding_id: '456')).to all(be_a Inventory::Service::Item)
    end

    it 'raises an ArgumentError if a parameter is missing' do
      expect { described_class.items(mms_id: '123', holding_id: nil) }.to raise_error ArgumentError
    end
  end

  describe '.fulfillment_options' do
    it 'returns an array of options' do
      item = build :item, :checkoutable
      expect(described_class.fulfillment_options(item: item, ils_group: 'group')).to be_an Array
    end

    context 'when the item is aeon requestable' do
      let(:item) { build :item, :aeon_requestable }

      it 'returns only aeon option' do
        expect(described_class.fulfillment_options(item: item, ils_group: 'group')).to eq [:aeon]
      end
    end

    context 'when the item is at archives' do
      let(:item) { build :item, :at_archives }

      it 'returns only archives option' do
        expect(described_class.fulfillment_options(item: item, ils_group: 'group')).to eq [:archives]
      end
    end

    context 'when the item is checkoutable' do
      let(:item) { build :item, :checkoutable }

      it 'returns pickup option' do
        options = described_class.fulfillment_options(item: item, ils_group: 'undergrad')
        expect(options).to include :pickup
      end

      it 'returns office option if ils_group is faculty express' do
        options = described_class.fulfillment_options(item: item, ils_group: 'FacEXP')
        expect(options).to include :office
      end

      it 'returns mail option if ils_group is not courtesy borrower' do
        options = described_class.fulfillment_options(item: item, ils_group: 'not_courtesy')
        expect(options).to include :mail
      end

      it 'returns scan option if item is scannable' do
        item = build :item, :scannable
        options = described_class.fulfillment_options(item: item, ils_group: 'group')
        expect(options).to include :scan
      end
    end
  end
end
