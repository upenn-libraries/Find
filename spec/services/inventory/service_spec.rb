# frozen_string_literal: true

describe Inventory::Service do
  describe '.full' do
    include_context 'with stubbed availability_data'

    let(:response) { described_class.full(document) }
    let(:mms_id) { '9979338417503681' }
    let(:document) { SolrDocument.new({ id: mms_id }) }

    context 'with a record having Physical inventory' do
      include_context 'with stubbed availability item_data'

      let(:availability_data) do
        { mms_id => { holdings: [build(:physical_availability_data)] } }
      end
      let(:item_data) { build(:item_data) }

      it 'returns a Inventory::Response object' do
        expect(response).to be_a Inventory::Response
      end

      it 'iterates over returned entries' do
        expect(response.first).to be_a Inventory::Entry
      end

      it 'retrieves format data for an item' do
        expect(response.first.format).to eq item_data['physical_material_type']['desc']
      end
    end

    context 'with a record having Electronic inventory' do
      let(:availability_data) do
        { mms_id => { holdings: [build(:electronic_availability_data),
                                 build(:electronic_availability_data, :unavailable)] } }
      end

      it 'does not include unavailable entries' do
        expect(response.collect(&:status)).not_to include Inventory::Constants::ELEC_UNAVAILABLE
      end
    end

    context 'with a record having only Ecollection inventory' do
      let(:availability_data) { { mms_id => { holdings: [] } } }
      let(:ecollections_data) { [{ id: ecollection_data['id'] }] }
      let(:ecollection_data) { build(:ecollection_data) }

      include_context 'with stubbed ecollections_data'
      include_context 'with stubbed ecollection_data'

      it 'returns a single electronic inventory entry' do
        expect(response.first).to be_a Inventory::Entry::Ecollection
      end

      it 'has the expected attribute values' do
        entry = response.first
        expect(entry.description).to eq ecollection_data['public_name_override']
        expect(entry.href).to eq ecollection_data['url_override']
      end
    end

    context 'with a record having 4 electronic inventory entries' do
      let(:availability_data) do
        { mms_id => { holdings: build_list(:electronic_availability_data, 4) } }
      end

      it 'returns all entries' do
        expect(response.count).to be 4
      end
    end
  end

  describe '.brief' do
    include_context 'with stubbed availability_data'
    include_context 'with stubbed availability item_data'

    let(:mms_id) { '9979338417503681' }
    let(:document) { SolrDocument.new({ id: mms_id }) }
    let(:response) { described_class.brief(document) }
    let(:availability_data) do
      { mms_id => { holdings: build_list(:physical_availability_data, 4) } }
    end
    let(:item_data) { build(:item_data) }

    # Mocking resource links.
    before do
      allow(document).to receive(:marc_resource_links).and_return(build_list(:resource_link_data, 3))
    end

    it 'returns a Inventory::Response object' do
      expect(response).to be_a Inventory::Response
    end

    it 'iterates over returned entries' do
      expect(response.first).to be_a Inventory::Entry
    end

    it 'returns only 5 entries' do
      expect(response.count).to be 5
    end

    it 'returns only 3 api entries' do
      expect(response.count(&:physical?)).to be Inventory::Service::DEFAULT_LIMIT
    end

    it 'returns only 2 resource links' do
      expect(response.count(&:resource_link?)).to be Inventory::Service::RESOURCE_LINK_LIMIT
    end
  end

  # TODO: add more substance here as this method is more clearly defined
  describe '.electronic_detail' do
    let(:mms_id) { '9977568423203681' }
    let(:portfolio_id) { '53596869850003681' }
    let(:collection_id) { '61468384380003681' }

    it 'returns an ElectronicDetail object' do
      value = described_class.electronic_detail(mms_id, portfolio_id, collection_id)
      expect(value).to be_an Inventory::ElectronicDetail
    end

    context 'when portfolio_id is nil' do
      let(:portfolio_id) { nil }

      it 'returns an ElectronicDetail object' do
        value = described_class.electronic_detail(mms_id, portfolio_id, collection_id)
        expect(value).to be_an Inventory::ElectronicDetail
      end
    end

    context 'when collection_id is nil' do
      let(:collection_id) { nil }

      it 'returns an ElectronicDetail object' do
        value = described_class.electronic_detail(mms_id, portfolio_id, collection_id)
        expect(value).to be_an Inventory::ElectronicDetail
      end
    end

    context 'when both electronic identifiers are nil' do
      let(:portfolio_id) { nil }
      let(:collection_id) { nil }

      it 'returns an ElectronicDetail object' do
        value = described_class.electronic_detail(mms_id, portfolio_id, collection_id)
        expect(value).to be_an Inventory::ElectronicDetail
      end
    end
  end

  describe '.create_entry' do
    let(:inventory_class) do
      described_class.send(:create_entry, '9999999999', data)
    end

    context 'with physical inventory type' do
      let(:data) { { inventory_type: Inventory::Entry::PHYSICAL } }

      it 'returns Inventory::Entry::Physical object' do
        expect(inventory_class).to be_a(Inventory::Entry::Physical)
      end
    end

    context 'with electronic inventory type' do
      let(:data) { { inventory_type: Inventory::Entry::ELECTRONIC } }

      it 'returns Inventory::Entry::Electronic object' do
        expect(inventory_class).to be_a(Inventory::Entry::Electronic)
      end
    end

    context 'with ecollection inventory type' do
      let(:data) { { inventory_type: Inventory::Entry::ECOLLECTION } }

      it 'returns Inventory::Entry::Electronic object' do
        expect(inventory_class).to be_a(Inventory::Entry::Ecollection)
      end
    end

    context 'with resource link inventory type' do
      let(:data) { { inventory_type: Inventory::Entry::RESOURCE_LINK, href: '', description: '', id: 1 } }

      it 'returns Inventory::Entry::ResourceLink object' do
        expect(inventory_class).to be_a(Inventory::Entry::ResourceLink)
      end
    end

    context 'with uncategorized inventory type' do
      let(:data) { { inventory_type: 'kitten' } }

      it 'raises an Import::Service::Error' do
        expect { inventory_class }.to raise_error(described_class::Error, "Type: 'kitten' not found")
      end
    end
  end
end
