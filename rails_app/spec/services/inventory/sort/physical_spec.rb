# frozen_string_literal: true

describe Inventory::Sort::Physical do
  let(:sorted_data) { described_class.new(data).sort }

  describe '#sort' do
    let(:data) do
      [{  'availability' => Inventory::Constants::UNAVAILABLE },
       {  'availability' => Inventory::Constants::AVAILABLE },
       {  'availability' => Inventory::Constants::CHECK_HOLDINGS }]
    end

    it 'puts available holdings first' do
      expect(sorted_data.first).to eq data.second
    end

    it 'puts unavailable holdings last' do
      expect(sorted_data.last).to eq data.first
    end

    context 'when there is a tie in availability' do
      let(:data) do
        [{ 'priority' => '3', 'availability' => Inventory::Constants::AVAILABLE },
         { 'priority' => '1', 'availability' => Inventory::Constants::UNAVAILABLE },
         { 'priority' => '2', 'availability' => Inventory::Constants::AVAILABLE }]
      end

      it 'sorts by priority' do
        expect(sorted_data).to eq [data.third, data.first, data.second]
      end
    end

    context 'when there is a tie in availability and priority' do
      let(:data) do
        [{ 'availability' => Inventory::Constants::AVAILABLE,
           'location_code' => 'stor',
           'coverage_statement' => 'hi',
           'priority' => '1' },
         { 'availability' => Inventory::Constants::AVAILABLE,
           'location_code' => 'afro',
           'priority' => '1' }]
      end

      it 'sorts based on location' do
        expect(sorted_data).to eq [data.second, data.first]
      end
    end

    context 'when there is a tie in availability, priority, and location' do
      let(:data) do
        [{ 'availability' => Inventory::Constants::AVAILABLE,
           'location_code' => 'vanp',
           'priority' => '1',
           'total_items' => '2',
           'non_available_items' => '1' },
         { 'availability' => Inventory::Constants::AVAILABLE,
           'location_code' => 'afro',
           'priority' => '1',
           'total_items' => '2',
           'non_available_items' => '0' }]
      end

      it 'sorts based on available items' do
        expect(sorted_data).to eq [data.second, data.first]
      end
    end

    context 'when there is a tie in availability, priority, location, and available items' do
      let(:data) do
        [{ 'availability' => Inventory::Constants::AVAILABLE,
           'location_code' => 'vanp',
           'priority' => '1',
           'total_items' => '2',
           'non_available_items' => '1' },
         { 'availability' => Inventory::Constants::AVAILABLE,
           'location_code' => 'afro',
           'priority' => '1',
           'total_items' => '2',
           'non_available_items' => '1',
           'coverage_statement' => 'lofty coverage' }]
      end

      it 'sorts based on coverage statement' do
        expect(sorted_data).to eq [data.second, data.first]
      end
    end
  end
end
