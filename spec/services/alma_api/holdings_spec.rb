# frozen_string_literal: true

describe AlmaApi::Holdings do
  let(:mms_id) { '9979338417503681' }

  describe '.find' do
    let(:bib_response) do
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
    let(:holdings) { described_class.find('9979338417503681') }

    before do
      availability_double = instance_double(Alma::AvailabilityResponse)
      allow(Alma::Bib).to receive(:get_availability).and_return(availability_double)
      allow(availability_double).to receive(:availability).and_return(bib_response)
    end

    it 'returns data' do
      expect(holdings.size).to eq(1)
      expect(holdings.first.class).to eq(AlmaApi::Holding)
    end
  end
end
