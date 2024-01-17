# frozen_string_literal: true

describe Inventory::Holding do
  let(:mms_id) { '9979338417503681' }
  let(:physical_holding) do
    described_class.new(mms_id, { 'holding_id' => '22810131440003681',
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
                                  'inventory_type' => 'physical' })
  end

  let(:electronic_holding) do
    described_class.new(mms_id, { 'portfolio_pid' => '53496697910003681',
                                  'collection_id' => '61496697940003681',
                                  'activation_status' => 'Available',
                                  'library_code' => 'VanPeltLib',
                                  'collection' => 'Nature Publishing Journals',
                                  'coverage_statement' => 'Available from 1869 volume: 1 issue: 1.',
                                  'interface_name' => 'Nature',
                                  'inventory_type' => 'electronic' })
  end

  describe '#status' do
    context 'with physical holding' do
      it 'returns status' do
        expect(physical_holding.status).to eq('available')
      end
    end

    context 'with electronic holding' do
      it 'returns status' do
        expect(electronic_holding.status).to eq('Available')
      end
    end
  end

  describe '#policy', pending: 'needs to be implemented' do
    context 'with physical holding' do
      it 'returns policy' do
        expect(physical_holding.policy).to eq('some policy')
      end
    end

    context 'with electronic holding' do
      it 'returns policy' do
        expect(electronic_holding.policy).to eq('some policy')
      end
    end
  end

  describe '#description' do
    context 'with physical holding' do
      it 'returns description' do
        expect(physical_holding.description).to eq('HQ801 .D43 1997')
      end
    end

    context 'with electronic holding' do
      it 'returns description' do
        expect(electronic_holding.description).to eq('Nature Publishing Journals')
      end
    end
  end

  describe '#format', pending: 'needs to be implemented' do
    context 'with physical holding' do
      it 'returns format' do
        expect(physical_holding.format).to eq('some format')
      end
    end

    context 'with electronic holding' do
      it 'returns format' do
        expect(electronic_holding.format).to eq('some format')
      end
    end
  end

  describe '#count' do
    context 'with physical holding' do
      it 'returns count' do
        expect(physical_holding.count).to eq('1')
      end
    end

    context 'with electronic holding' do
      it 'returns count' do
        expect(electronic_holding.count).to eq('')
      end
    end
  end

  describe '#location' do
    context 'with physical holding' do
      it 'returns location' do
        expect(physical_holding.location).to eq('Van Pelt Library')
      end
    end

    context 'with electronic holding' do
      it 'returns location' do
        expect(electronic_holding.location).to eq('')
      end
    end
  end

  describe '#id' do
    context 'with physical holding' do
      it 'returns id' do
        expect(physical_holding.id).to eq('22810131440003681')
      end
    end

    context 'with electronic holding' do
      it 'returns id' do
        expect(electronic_holding.id).to eq('53496697910003681')
      end
    end
  end

  describe '#href' do
    context 'with physical holding' do
      it 'returns href' do
        expect(physical_holding.href).to eq('/catalog/9979338417503681#22810131440003681')
      end
    end

    context 'with electronic holding' do
      it 'returns href' do
        expect(electronic_holding.href).to eq(
          'https://upenn.alma.exlibrisgroup.com/view/uresolver/01UPENN_INST/openurl?Force_direct=true&portfolio_pid=' \
          "#{electronic_holding.id}&rfr_id=info%3Asid%2Fprimo.exlibrisgroup.com&u.ignore_date_coverage=true"
        )
      end
    end
  end

  describe '#type' do
    context 'with physical holding' do
      it 'returns type' do
        expect(physical_holding.type).to eq('physical')
      end
    end

    context 'with electronic holding' do
      it 'returns type' do
        expect(electronic_holding.type).to eq('electronic')
      end
    end
  end

  describe 'to_h' do
    context 'with physical holding' do
      it 'returns formatted hash' do
        expect(physical_holding.to_h).to eq({ count: '1', description: 'HQ801 .D43 1997', format: '',
                                              href: '/catalog/9979338417503681#22810131440003681',
                                              id: '22810131440003681', location: 'Van Pelt Library', policy: '',
                                              status: 'available', type: 'physical' })
      end
    end

    context 'with electronic holding' do
      it 'returns formatted hash' do
        expect(electronic_holding.to_h).to eq({ count: '', description: 'Nature Publishing Journals', format: '', href:
          'https://upenn.alma.exlibrisgroup.com/view/uresolver/01UPENN_INST/openurl?Force_direct=true&portfolio_pid=' \
          '53496697910003681&rfr_id=info%3Asid%2Fprimo.exlibrisgroup.com&u.ignore_date_coverage=true',
                                                id: '53496697910003681', location: '', policy: '', status: 'Available',
                                                type: 'electronic' })
      end
    end
  end
end
