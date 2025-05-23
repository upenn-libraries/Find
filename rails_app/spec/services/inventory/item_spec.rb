# frozen_string_literal: true

describe Inventory::Item do
  describe '.find' do
    before do
      allow(Alma::BibItem).to receive(:find_one).and_return(Alma::BibItem.new({}))
    end

    it 'returns a Item' do
      expect(described_class.find(mms_id: '123', holding_id: '456', item_id: '789'))
        .to be_a described_class
    end

    it 'raises an ArgumentError if a parameter is missing' do
      expect { described_class.find(mms_id: '123', holding_id: '456', item_id: nil) }.to raise_error ArgumentError
    end
  end

  describe '.find_all' do
    let(:bib_item) { build(:item).bib_item }
    let(:items) { described_class.find_all(mms_id: '123', holding_id: '456') }

    it 'raises an ArgumentError if a parameter is missing' do
      expect { described_class.find_all(mms_id: nil, holding_id: nil) }.to raise_error ArgumentError
    end

    context 'when items are present' do
      before do
        bib_item_set_double = instance_double(Alma::BibItemSet, items: [bib_item], total_record_count: 1)
        allow(Alma::BibItem).to receive(:find).and_return(bib_item_set_double)
      end

      it 'returns an array of items' do
        expect(items.first).to be_a described_class
      end
    end

    context 'when items are not present' do
      before do
        bib_item_set_double = instance_double(Alma::BibItemSet, items: [], total_record_count: 0)
        allow(Alma::BibItem).to receive(:find).and_return(bib_item_set_double)
        allow(Alma::BibHolding).to receive(:find_all).and_return('holding' => [{ 'holding_id' => '456' }])
      end

      it 'returns an item generated from the holding' do
        expect(items.first).to be_a described_class
        expect(items.first.holding_data['holding_id']).to eq '456'
      end
    end

    context 'when record is a boundwith and a holding_record_id is present' do
      let(:bib_set) { create(:alma_bib_set) }
      let(:items) { described_class.find_all(mms_id: '123', holding_id: '456', host_record_id: '789') }

      before do
        bib_item_set_double = instance_double(Alma::BibItemSet,
                                              items: [bib_item], total_record_count: 1, first: bib_item)
        allow(Alma::BibItem).to receive(:find).with('789', holding_id: '456').and_return(bib_item_set_double)
        allow(Alma::Bib).to receive(:find).and_return(bib_set)
      end

      it 'returns an array of Inventory::Item' do
        expect(items.first).to be_a described_class
      end

      it 'returns an item composed from the holding and child record' do
        expect(items.first.bib_data).to include bib_set.response['bib'].first
        expect(items.first.item_data).to eql bib_item.item_data
      end

      it 'returns an item marked as boundwith' do
        expect(items.first.boundwith?).to be true
      end
    end

    context 'when holding data is blank' do
      before do
        bib_item_set_double = instance_double(Alma::BibItemSet, items: [], total_record_count: 0)
        allow(Alma::BibItem).to receive(:find).and_return(bib_item_set_double)
        allow(Alma::BibHolding).to receive(:find_all).and_return({})
      end

      it 'raises an error' do
        expect { described_class.find_all(mms_id: '123', holding_id: '456') }.to raise_error('Record has no holding.')
      end
    end

    context 'when record has a item in a temp location' do
      let(:temp_loc_bib_item) { build(:item, :in_temp_location).bib_item }
      let(:items) do
        described_class.find_all(mms_id: '123', holding_id: holding_id,
                                 location_code: temp_loc_bib_item.location)
      end

      before do
        bib_item_set_double = instance_double(Alma::BibItemSet,
                                              items: [temp_loc_bib_item, bib_item], total_record_count: 2)
        allow(Alma::BibItem).to receive(:find).and_return(bib_item_set_double)
      end

      context 'when the holding_id is nil (temp location case)' do
        let(:holding_id) { nil }

        it 'returns a single item in a temp location' do
          expect(items.count).to eq 1
          expect(items.first.in_temp_location?).to be true
        end
      end

      context 'when the holding_id is set' do
        let(:holding_id) { bib_item.holding_data['holding_id'] }

        it 'returns a single item not in a temp location' do
          expect(items.count).to eq 1
          expect(items.first.in_temp_location?).to be false
        end
      end
    end
  end

  describe '.fetch_all_items' do
    it 'makes multiple calls to Alma when total record count exceeds limit' do
      bib_item_set_double = instance_double(Alma::BibItemSet, items: build_list(:item, 2), total_record_count: 4)
      allow(Alma::BibItem).to receive(:find).and_return(bib_item_set_double)

      described_class.send(:fetch_all_items, mms_id: '1234', holding_id: '1234', limit: 2)
      expect(Alma::BibItem).to have_received(:find).twice
    end
  end

  describe '#bib_data' do
    let(:item) { build :item }

    it 'returns a Hash' do
      expect(item.bib_data).to be_a Hash
    end

    it 'returns the bib data' do
      expect(item.bib_data).to eq(item.bib_item['bib_data'])
    end
  end

  describe '#policy' do
    context 'with a record in a temporary location' do
      let(:item) { build :item, :in_temp_location }

      it 'returns the temp_policy value from the holding data' do
        expect(item.policy).to eq 'reserves'
      end
    end

    context 'with a record not in a temporary location' do
      let(:item) { build :item }

      it 'returns the policy vale from the item data' do
        expect(item.policy).to eq 'book/seria'
      end
    end
  end

  describe '#user_due_date_policy' do
    let(:item) { build :item, :not_loanable }

    it 'returns a String' do
      expect(item.user_due_date_policy).to be_a String
    end

    it 'returns the due date policy' do
      expect(item.user_due_date_policy).to eq Settings.fulfillment.due_date_policy.not_loanable
    end
  end

  describe '#location' do
    context 'when in permanent location' do
      let(:item) { build :item }

      it 'return Inventory::Location with permanent location code' do
        expect(item.location).to be_a Inventory::Location
        expect(item.location.code).to eql item.bib_item.location
      end
    end

    context 'when in temporary location' do
      let(:item) { build :item, :in_temp_location }

      it 'returns Inventory::Location with temporary location code' do
        expect(item.location).to be_a Inventory::Location
        expect(item.location.code).to eql item.bib_item.temp_location
      end
    end

    context 'when location information not in item_data' do
      let(:item) { build :item, :without_item }

      it 'return Inventory::Location with holding location code' do
        expect(item.location).to be_a Inventory::Location
        expect(item.location.code).to eql item.bib_item.holding_data['location']['value']
      end
    end
  end

  describe '#select_label' do
    it 'returns the correct label for the item' do
      item = build :item
      expect(item.select_label).to contain_exactly(
        "#{item.description} - #{item.physical_material_type['desc']} - #{item.location.library_name}",
        item.item_data['pid']
      )
    end
  end

  describe '#temp_aware_location_display' do
    it 'returns temp location display when item is in temp location' do
      item = build :item, :in_temp_location
      expect(item.temp_aware_location_display)
        .to eq "(temp) #{item.holding_data['temp_library']['desc']} - #{item.holding_data['temp_location']['desc']}"
    end

    it 'returns normal location display when item is not in temp location' do
      item = build :item
      expect(item.temp_aware_location_display)
        .to eq "#{item.bib_item.holding_library_name} - #{item.bib_item.holding_location_name}"
    end
  end

  describe '#request_options_list' do
    context 'when item_data is present' do
      let(:item) { build :item }

      it 'returns an array of request options' do
        expect(item.request_options_list).to be_a Array
      end
    end

    context 'when item_data is not present' do
      let(:item) { build :item, :without_item }

      it 'returns an empty array' do
        expect(item.request_options_list).to be_empty
      end
    end
  end
end
