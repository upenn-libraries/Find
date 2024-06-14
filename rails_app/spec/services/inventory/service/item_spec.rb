# frozen_string_literal: true

describe Inventory::Service::Item do
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

  describe 'select_label' do
    it 'returns the correct label for the item' do
      item = build :item
      expect(item.select_label)
        .to contain_exactly "#{item.description} - #{item.physical_material_type['desc']} - #{item.library_name}",
                            item.item_data['pid']
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

      it 'returns scan option if item is scannable' do
        item = build :item
        options = item.fulfillment_options(ils_group: 'group')
        expect(options).to include Fulfillment::Request::Options::ELECTRONIC
      end
    end
  end
end
