# frozen_string_literal: true

describe Inventory::Sort::Electronic do
  describe '.sort' do
    let(:sorted_data) { described_class.new(data).sort }
    let(:data) do
      [build(:electronic_availability_data, interface_name: 'Nature'),
       build(:electronic_availability_data, collection: 'Publisher website')]
    end

    it 'sorts by highest valued collection or interface' do
      expect(sorted_data).to eq [data.last, data.first]
    end

    context 'when there is a tie in the collection or interface value' do
      let(:data) do
        [{ 'collection' => 'd' }, { 'collection' => 'b' }, { 'collection' => 'c' }, { 'interface_name' => 'a' }]
      end

      it 'sorts by collection name' do
        expect(sorted_data).to eq [data.second, data.third, data.first, data.last]
      end
    end
  end
end
