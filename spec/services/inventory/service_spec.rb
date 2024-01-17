# frozen_string_literal: true

describe Inventory::Service do
  let(:sample_electronic_bib_response) do
    { '9979338417503681' =>
        { holdings: [{ 'portfolio_pid' => '53478314060003681',
                       'collection_id' => '61468362070003681',
                       'activation_status' => 'Available',
                       'collection' => 'Factiva',
                       'coverage_statement' => 'Available from 01/01/1997 until 12/31/2021.',
                       'interface_name' => 'Factiva',
                       'inventory_type' => 'electronic' },
                     { 'portfolio_pid' => '53693946490003681',
                       'collection_id' => '61692149360003681',
                       'activation_status' => 'Available',
                       'collection' => 'Education Magazine Archive',
                       'coverage_statement' => 'Available from 01/02/1919 until 12/31/1971.',
                       'interface_name' => 'ProQuest',
                       'inventory_type' => 'electronic' },
                     { 'portfolio_pid' => '53526992570003681',
                       'collection_id' => '61468377400003681',
                       'activation_status' => 'Available',
                       'collection' => 'PressReader',
                       'coverage_statement' => 'Available from 07/28/2017 until 12/24/2021.',
                       'interface_name' => 'PressReader',
                       'inventory_type' => 'electronic' }] } }
  end

  let(:sample_physical_bib_response) do
    { '9977048531103681' =>
        { holdings: [{ 'holding_id' => '22810131440003681',
                       'institution' => '01UPENN_INST',
                       'library_code' => 'VanPeltLib',
                       'location' => 'Stacks',
                       'call_number' => 'HQ801 .D43 1997',
                       'availability' => 'available',
                       'total_items' => '1',
                       'non_available_items' => '0',
                       'location_code' => 'vanp',
                       'call_number_type' => '0',
                       'priority' => '1',
                       'library' => 'Van Pelt Library',
                       'inventory_type' => 'physical' }] } }
  end

  describe '.find' do
    let(:inventory) { described_class.find('9977048531103681') }

    before do
      availability_double = instance_double(Alma::AvailabilityResponse)
      allow(Alma::Bib).to receive(:get_availability).and_return(availability_double)
      allow(availability_double).to receive(:availability).and_return(sample_physical_bib_response)
    end

    it 'returns expected inventory data' do
      expect(inventory).to eq([{ count: '1', description: 'HQ801 .D43 1997', format: '',
                                 href: '/catalog/9977048531103681#22810131440003681', id: '22810131440003681',
                                 location: 'Van Pelt Library', policy: '', status: 'available', type: 'physical' }])
    end
  end

  describe '.find_many' do
    let(:inventory) { described_class.find_many(%w[9979338417503681 9977048531103681], 1) }
    let(:response) { sample_physical_bib_response.merge(sample_electronic_bib_response) }

    before do
      availability_double = instance_double(Alma::AvailabilityResponse)
      allow(Alma::Bib).to receive(:get_availability).and_return(availability_double)
      allow(availability_double).to receive(:availability).and_return(response)
    end

    it 'returns expected inventory data' do
      expect(inventory.size).to eq 2
    end

    it 'has the inventory data for each mms_id' do
      expect(inventory.last).to(
        eq({:'9977048531103681' => {inventory: [{ count: '1', description: 'HQ801 .D43 1997', id: '22810131440003681',
                                                  location: 'Van Pelt Library', policy: '', status: 'available',
                                                  type: 'physical', href: '/catalog/9977048531103681#22810131440003681',
                                                  format: '' }]}})
      )
    end
  end
end