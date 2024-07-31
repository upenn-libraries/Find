# frozen_string_literal: true

describe Inventory::List::Sort::Factory do
  describe '.create' do
    let(:sorter) { described_class.create(data) }

    context 'with physical holdings' do
      let(:data) { [build(:physical_availability_data)] }

      it 'returns an Inventory::Sort::Physical object' do
        expect(sorter).to be_a Inventory::List::Sort::Physical
      end
    end

    context 'with electronic holdings' do
      let(:data) { [build(:electronic_availability_data)] }

      it 'returns an Inventory::Sort::Electronic object' do
        expect(sorter).to be_a Inventory::List::Sort::Electronic
      end
    end

    context 'with ecollection holdings' do
      let(:data) do
        [build(:ecollection_data).merge({ 'inventory_type' => Inventory::List::ECOLLECTION })]
      end

      it 'returns an Inventory::Sort::Electronic object' do
        expect(sorter).to be_a Inventory::List::Sort::Electronic
      end
    end

    context 'with an unknown type' do
      let(:data) { [{ 'inventory_type' => 'unknown' }] }

      it 'returns the base sorting class' do
        expect(sorter).to be_a Inventory::List::Sort::Base
      end
    end

    context 'when inventory data is nil' do
      let(:data) { nil }

      it 'returns the base sorting class' do
        expect(sorter).to be_a Inventory::List::Sort::Base
      end

      it 'initializes base sorting class with empty array' do
        expect(sorter.inventory_data).to eq []
      end
    end
  end
end
