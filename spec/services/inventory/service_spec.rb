# frozen_string_literal: true

describe Inventory::Service do
  let(:bib_response) do
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
      allow(availability_double).to receive(:availability).and_return(bib_response)
    end

    it 'returns expected inventory data' do
      expect(inventory).to eq([{ count: '1', description: 'HQ801 .D43 1997', format: nil,
                                 href: '/catalog/9977048531103681#22810131440003681', id: '22810131440003681',
                                 location: 'Van Pelt Library', policy: nil, status: 'available', type: 'physical' }])
    end
  end

  describe '.find_many' do
    let(:inventory) { described_class.find_many(%w[id1 id2]) }
    let(:response) do
      { 'id1' => { holdings: [{ 'inventory_type' => 'electronic' }] },
        'id2' => { holdings: [{ 'inventory_type' => 'physical' }] } }
    end

    before do
      availability_double = instance_double(Alma::AvailabilityResponse)
      allow(Alma::Bib).to receive(:get_availability).and_return(availability_double)
      allow(availability_double).to receive(:availability).and_return(response)
    end

    it 'returns expected inventory data' do
      expect(inventory.size).to eq 2
    end

    it 'has the inventory data for each mms_id' do
      expect(inventory).to contain_exactly(
        { id1: [{ status: nil, policy: nil, description: nil, format: nil, count: nil, location: nil, id: nil,
                  href: nil, type: 'electronic' }] }, { id2: [{ status: nil, policy: nil, description: nil, format: nil,
                                                                count: nil, location: nil, id: nil, href: nil,
                                                                type: 'physical' }] })
    end
  end
end