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

  describe 'checkoutable?' do
    it 'returns true if item is checkoutable' do
      item = build :item, :checkoutable
      expect(item.checkoutable?).to be true
    end

    it 'returns false if item is not checkoutable' do
      item = build :item, :aeon_requestable
      expect(item.checkoutable?).to be false
    end
  end

  describe 'bib_data' do
    let(:item) { build :item }

    it 'returns a Hash' do
      expect(item.bib_data).to be_a Hash
    end

    it 'returns the bib data' do
      expect(item.bib_data).to eq(item.item['bib_data'])
    end
  end

  describe 'user_due_date_policy' do
    let(:item) { build :item, :not_checkoutable }

    it 'returns a String' do
      expect(item.user_due_date_policy).to be_a String
    end

    it 'returns the due date policy' do
      expect(item.user_due_date_policy).to eq 'Not loanable'
    end
  end

  describe 'loanable?' do
    it 'returns true if item is loanable' do
      item = build :item, :checkoutable
      expect(item.loanable?).to be true
    end

    it 'returns false if item is not loanable' do
      item = build :item, :not_checkoutable
      expect(item.loanable?).to be false
    end
  end

  describe 'aeon_requestable?' do
    it 'returns true if item is aeon requestable' do
      item = build :item, :aeon_requestable
      expect(item.aeon_requestable?).to be true
    end

    it 'returns false if item is not aeon requestable' do
      item = build :item, :checkoutable
      expect(item.aeon_requestable?).to be false
    end
  end

  describe 'scannable?' do
    it 'returns true if item is scannable' do
      item = build :item
      expect(item.scannable?).to be true
    end

    it 'returns false if item is not scannable' do
      item = build :item, :not_scannable
      expect(item.scannable?).to be false
    end
  end

  describe 'at_hsp?' do
    it 'returns true if item is at HSP' do
      item = build :item, :at_hsp
      expect(item.at_hsp?).to be true
    end

    it 'returns false if item is not at HSP' do
      item = build :item, :checkoutable
      expect(item.at_hsp?).to be false
    end
  end

  describe 'on_reserve?' do
    it 'returns true if item is on reserve' do
      item = build :item, :on_reserve
      expect(item.on_reserve?).to be true
    end

    it 'returns false if item is not on reserve' do
      item = build :item, :checkoutable
      expect(item.on_reserve?).to be false
    end
  end

  describe 'at_reference?' do
    it 'returns true if item is at reference' do
      item = build :item, :at_reference
      expect(item.at_reference?).to be true
    end

    it 'returns false if item is not at reference' do
      item = build :item, :checkoutable
      expect(item.at_reference?).to be false
    end
  end

  describe 'at_archives?' do
    it 'returns true if item is at archives' do
      item = build :item, :at_archives
      expect(item.at_archives?).to be true
    end

    it 'returns false if item is not at archives' do
      item = build :item, :checkoutable
      expect(item.at_archives?).to be false
    end
  end

  describe 'in_house_use_only?' do
    it 'returns true if item is in house use only' do
      item = build :item, :in_house_use_only
      expect(item.in_house_use_only?).to be true
    end

    it 'returns false if item is not in house use only' do
      item = build :item, :checkoutable
      expect(item.in_house_use_only?).to be false
    end
  end

  describe 'unavailable?' do
    it 'returns true if item is not checkoutable nor aeon requestable' do
      item = build(:item, :not_aeon_requestable, :not_checkoutable)
      expect(item.unavailable?).to be true
    end

    it 'returns false if item is not checkoutable but is aeon requestable' do
      item = build(:item, :not_checkoutable, :aeon_requestable)
      expect(item.unavailable?).to be false
    end

    it 'returns false if item is checkoutable' do
      item = build(:item, :checkoutable)
      expect(item.unavailable?).to be false
    end
  end

  describe 'select_label' do
    it 'returns the correct label for the item' do
      item = build :item
      expect(item.select_label)
        .to contain_exactly "#{item.description} - #{item.physical_material_type['desc']} - #{item.library_name}",
                            item.item_data['pid']
    end
  end

  describe 'temp_aware_location_display' do
    it 'returns temp location display when item is in temp location' do
      item = build :item, :in_temp_location
      expect(item.temp_aware_location_display)
        .to eq "(temp) #{item.holding_data['temp_library']['value']} - #{item.holding_data['temp_location']['value']}"
    end

    it 'returns normal location display when item is not in temp location' do
      item = build :item
      expect(item.temp_aware_location_display)
        .to eq "#{item.holding_library_name} - #{item.holding_location_name}"
    end
  end

  describe 'temp_aware_call_number' do
    it 'returns the temp call number when it exists' do
      item = build :item, :in_temp_location
      expect(item.temp_aware_call_number).to eq item.holding_data['temp_call_number']
    end

    it 'returns the normal call number when item is not in temp location' do
      item = build :item
      expect(item.temp_aware_call_number).to eq item.holding_data['permanent_call_number']
    end
  end

  describe 'fulfillment_options' do
    let(:user) { create(:user) }
    let(:options) { item.fulfillment_options(user: user) }
    let(:item) { build :item, :checkoutable }

    it 'returns an array of options' do
      expect(options).to be_an Array
    end

    context 'when the item is aeon requestable' do
      let(:item) { build :item, :aeon_requestable }

      context 'with user' do
        it 'returns only aeon option' do
          expect(options).to eq [:aeon]
        end
      end

      context 'without user' do
        let(:user) { nil }

        it 'returns only aeon option' do
          expect(options).to eq [:aeon]
        end
      end
    end

    context 'when the item is at archives' do
      let(:item) { build :item, :at_archives }

      context 'with user' do
        it 'returns only archives option' do
          expect(options).to eq [:archives]
        end
      end

      context 'without user' do
        let(:user) { nil }

        it 'returns only archives option' do
          expect(options).to eq [:archives]
        end
      end
    end

    context 'when the item is checkoutable' do
      let(:item) { build :item, :checkoutable }

      it 'returns pickup option' do
        expect(options).to include Fulfillment::Request::Options::PICKUP
      end

      it 'returns electronic option if item is scannable' do
        expect(options).to include Fulfillment::Request::Options::ELECTRONIC
      end

      it 'returns mail option if user is not courtesy borrower' do
        expect(options).to include Fulfillment::Request::Options::MAIL
      end

      context 'with faculty express user' do
        let(:user) { create(:user, :faculty_express) }

        it 'returns office option' do
          expect(options).to include Fulfillment::Request::Options::OFFICE
        end
      end

      context 'with courtesy borrower' do
        let(:user) { create(:user, :courtesy_borrower) }

        it 'returns only pickup option' do
          expect(options).to contain_exactly(Fulfillment::Request::Options::PICKUP)
        end
      end
    end

    context 'when the item is unavailable' do
      let(:item) { build :item, :not_checkoutable }

      it 'returns electronic option' do
        expect(options).to include Fulfillment::Request::Options::ELECTRONIC
      end

      it 'returns ill pickup option' do
        expect(options).to include Fulfillment::Request::Options::ILL_PICKUP
      end

      it 'returns books by mail option' do
        expect(options).to include Fulfillment::Request::Options::MAIL
      end

      context 'with faculty express user' do
        let(:user) { create(:user, :faculty_express) }

        it 'returns office option' do
          expect(options).to include Fulfillment::Request::Options::OFFICE
        end
      end

      context 'with courtesy borrower' do
        let(:user) { create(:user, :courtesy_borrower) }

        it 'returns no options' do
          expect(options).to be_empty
        end
      end
    end
  end
end
