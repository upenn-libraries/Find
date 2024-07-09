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
  end
end
