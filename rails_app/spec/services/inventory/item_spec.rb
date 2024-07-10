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
    let(:item) { described_class.find_all(mms_id: '123', holding_id: '456').first }

    it 'returns an array of PennItems when items are present' do
      bib_item_set_double = instance_double(Alma::BibItemSet, items: [bib_item], total_record_count: 1)
      allow(Alma::BibItem).to receive(:find).and_return(bib_item_set_double)
      expect(item).to be_a described_class
    end

    it 'returns an array of PennItems when items are not present' do
      bib_item_set_double = instance_double(Alma::BibItemSet, items: [], total_record_count: 0)
      allow(Alma::BibItem).to receive(:find).and_return(bib_item_set_double)
      allow(Alma::BibHolding).to receive(:find_all).and_return('holding' => [{ 'holding_id' => '456' }])
      expect(item).to be_a described_class
      expect(item.holding_data['holding_id']).to eq '456'
    end

    it 'returns an empty array when holding data is blank' do
      bib_item_set_double = instance_double(Alma::BibItemSet, items: [], total_record_count: 0)
      allow(Alma::BibItem).to receive(:find).and_return(bib_item_set_double)
      allow(Alma::BibHolding).to receive(:find_all).and_return({})
      expect(described_class.find_all(mms_id: '123', holding_id: '456')).to eq []
    end

    it 'raises an ArgumentError if a parameter is missing' do
      expect { described_class.find_all(mms_id: '123', holding_id: nil) }.to raise_error ArgumentError
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
    it 'returns an array of options' do
      item = build :item, :checkoutable
      expect(item.fulfillment_options(ils_group: 'group')).to be_an Array
    end

    context 'when the item is aeon requestable' do
      let(:item) { build :item, :aeon_requestable }

      it 'returns only aeon option' do
        expect(item.fulfillment_options(ils_group: 'group')).to eq [:aeon]
      end
    end

    context 'when the item is at archives' do
      let(:item) { build :item, :at_archives }

      it 'returns only archives option' do
        expect(item.fulfillment_options(ils_group: 'group')).to eq [:archives]
      end
    end

    context 'when the item is checkoutable' do
      let(:item) { build :item, :checkoutable }

      it 'returns pickup option' do
        options = item.fulfillment_options(ils_group: 'undergrad')
        expect(options).to include Fulfillment::Request::Options::PICKUP
      end

      it 'returns office option if ils_group is faculty express' do
        options = item.fulfillment_options(ils_group: 'FacEXP')
        expect(options).to include Fulfillment::Request::Options::OFFICE
      end

      it 'returns mail option if ils_group is not courtesy borrower' do
        options = item.fulfillment_options(ils_group: 'not_courtesy')
        expect(options).to include Fulfillment::Request::Options::MAIL
      end

      it 'returns electronic option if item is scannable' do
        item = build :item
        options = item.fulfillment_options(ils_group: 'group')
        expect(options).to include Fulfillment::Request::Options::ELECTRONIC
      end
    end

    context 'when the item is unavailable' do
      let(:item) { build :item, :not_checkoutable }
      let(:options) { item.fulfillment_options(ils_group: 'group') }

      it 'returns electronic option' do
        expect(options).to include Fulfillment::Request::Options::ELECTRONIC
      end

      it 'returns ill pickup option' do
        expect(options).to include Fulfillment::Request::Options::ILL_PICKUP
      end

      it 'returns books by mail option if the user is not a courtesy borrower' do
        expect(options).to include Fulfillment::Request::Options::MAIL
      end

      it 'returns office option if ils_group is faculty express' do
        expect(item.fulfillment_options(ils_group: User::FACULTY_EXPRESS_GROUP))
          .to include Fulfillment::Request::Options::OFFICE
      end
    end
  end
end
