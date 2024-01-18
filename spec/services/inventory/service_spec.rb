# frozen_string_literal: true

describe Inventory::Service do
  let(:data) do
    { '9979338417503681' =>
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
    let(:inventory) { described_class.find('9979338417503681') }

    before do
      availability_double = instance_double(Alma::AvailabilityResponse)
      allow(Alma::Bib).to receive(:get_availability).and_return(availability_double)
      allow(availability_double).to receive(:availability).and_return(data)
    end

    it 'returns expected hash value' do
      expect(inventory).to eq({ inventory: [{ count: '1', description: 'HQ801 .D43 1997', format: nil,
                                              href: '/catalog/9979338417503681#22810131440003681',
                                              id: '22810131440003681', location: 'Van Pelt Library', policy: nil,
                                              status: 'available', type: 'physical' }],
                                total: 1 })
    end
  end

  describe '.find_many' do
    let(:inventory) { described_class.find_many(%w[id1 id2]) }
    let(:data) do
      { 'id1' => { holdings: [{ 'inventory_type' => 'electronic' }] },
        'id2' => { holdings: [{ 'inventory_type' => 'physical' }] } }
    end

    before do
      availability_double = instance_double(Alma::AvailabilityResponse)
      allow(Alma::Bib).to receive(:get_availability).and_return(availability_double)
      allow(availability_double).to receive(:availability).and_return(data)
    end

    it 'returns the expected hash value' do
      expect(inventory).to eq({ id1: { inventory: [{ status: nil, policy: nil, description: nil, format: nil, id: nil,
                                                     count: nil, location: nil, href: nil, type: 'electronic' }],
                                       total: 1 }, id2: { inventory: [{ status: nil, policy: nil, description: nil,
                                                                        format: nil, id: nil, location: nil, count: nil,
                                                                        href: nil, type: 'physical' }], total: 1 } })
    end

    context 'when provided more mms_ids than allowed' do
      let(:mms_ids) { Array.new(described_class::MAX_BIBS_GET + 1, 'id') }

      let(:inventory) { described_class.find_many(mms_ids) }

      it 'raises error' do
        expect { inventory }.to raise_error(
          described_class::Error, "Too many MMS IDs provided, exceeds max allowed of #{described_class::MAX_BIBS_GET}."
        )
      end
    end
  end

  describe '.create' do
    let(:inventory_class) { described_class.create(type, '9999999999', {}) }

    context 'with physical inventory type' do
      let(:type) { described_class::PHYSICAL }

      it 'returns Inventory::Physical object' do
        expect(inventory_class).to be_a(Inventory::Physical)
      end
    end

    context 'with electronic inventory type' do
      let(:type) { described_class::ELECTRONIC }

      it 'returns Inventory::Electronic object' do
        expect(inventory_class).to be_a(Inventory::Electronic)
      end
    end

    context 'with uncategorized inventory type' do
      let(:type) { 'unknown' }

      it 'raises an Import::Service::Error' do
        expect { inventory_class }.to raise_error(described_class::Error, "Type: 'unknown' not found")
      end
    end
  end
end
