# frozen_string_literal: true

describe Inventory::List do
  let(:document) { SolrDocument.new({ id: mms_id }) }

  context 'when the SRU call times out' do
    let(:mms_id) { '9979240322003681' }

    before do
      stub_request(:any, /#{Settings.alma.sru_endpoint}/).to_timeout
    end

    it 'returns a response object marked as not complete' do
      expect(described_class.full(document).complete?).to be false
      expect(described_class.brief(document).complete?).to be false
    end
  end

  describe '.full' do
    include_context 'with stubbed SRU availability_data'

    let(:response) { described_class.full(document) }
    let(:mms_id) { '9979338417503681' }

    context 'with a record having Physical inventory' do
      include_context 'with stubbed availability item_data'

      let(:availability_data) do
        { mms_id => { holdings: [build(:physical_availability_data)] } }
      end
      let(:item_data) { build(:item_data) }

      it 'returns a Inventory::Response object' do
        expect(response).to be_a Inventory::List::Response
      end

      it 'iterates over returned entries' do
        expect(response.first).to be_a Inventory::List::Entry::Base
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

    context 'with a record having only quality Ecollection inventory' do
      let(:availability_data) { { mms_id => { holdings: [] } } }
      let(:ecollection_data) { build(:ecollection_data) }

      include_context 'with stubbed ecollections_data'
      include_context 'with stubbed ecollection_data'

      it 'returns only a single ecollection inventory entry' do
        expect(response.entries.length).to eq 1
        expect(response.first).to be_a Inventory::List::Entry::Ecollection
      end

      it 'has the expected attribute values' do
        entry = response.first
        expect(entry.description).to eq ecollection_data['public_name_override']
        expect(entry.href).to eq ecollection_data['url_override']
      end

      it 'entry includes public note' do
        entry = response.first
        expect(entry.public_note).to eq ecollection_data['public_note']
      end
    end

    context 'with a record having poorly coded Ecollection inventory' do
      let(:availability_data) { { mms_id => { holdings: [] } } }
      let(:ecollection_data) { build(:ecollection_data, url: '', url_override: '') }

      include_context 'with stubbed ecollections_data'
      include_context 'with stubbed ecollection_data'

      it 'does not return any ecollection inventory' do
        expect(response.entries.length).to eq 0
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

    context 'with a record having physical inventory in a temporary location' do
      let(:availability_data) do
        { mms_id => { holdings: [build(:physical_availability_data, :in_temp_location)] } }
      end

      it 'returns an entry for the temporary location holding with no holding id set' do
        expect(response.count).to be 1
        expect(response.first.id).to be_nil
      end
    end

    context 'when inventory data is nil' do
      let(:availability_data) { { mms_id => { holdings: nil } } }

      it 'returns no entries' do
        expect(response.entries).to be_empty
      end
    end
  end

  describe '.brief' do
    include_context 'with stubbed SRU availability_data'
    include_context 'with stubbed availability item_data'

    let(:mms_id) { '9979338417503681' }
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
      expect(response).to be_a Inventory::List::Response
    end

    it 'iterates over returned entries' do
      expect(response.first).to be_a Inventory::List::Entry::Base
    end

    it 'returns only 5 entries' do
      expect(response.count).to be 5
    end

    it 'returns only 3 api entries' do
      expect(response.count(&:physical?)).to be Inventory::List::DEFAULT_LIMIT
    end

    it 'returns only 2 resource links' do
      expect(response.count(&:resource_link?)).to be Inventory::List::RESOURCE_LINK_LIMIT
    end
  end

  describe '.create_entry' do
    let(:inventory_class) do
      described_class.send(:create_entry, '9999999999', **data)
    end

    context 'with physical inventory type' do
      let(:data) { { inventory_type: Inventory::List::PHYSICAL } }

      it 'returns Inventory::Entry::Physical object' do
        expect(inventory_class).to be_a(Inventory::List::Entry::Physical)
      end
    end

    context 'with electronic inventory type' do
      let(:data) { { inventory_type: Inventory::List::ELECTRONIC } }

      it 'returns Inventory::Entry::Electronic object' do
        expect(inventory_class).to be_a(Inventory::List::Entry::Electronic)
      end
    end

    context 'with ecollection inventory type' do
      let(:data) { { inventory_type: Inventory::List::ECOLLECTION } }

      it 'returns Inventory::Entry::Ecollection object' do
        expect(inventory_class).to be_a(Inventory::List::Entry::Ecollection)
      end
    end

    context 'with resource link inventory type' do
      let(:data) { { inventory_type: Inventory::List::RESOURCE_LINK, href: '', description: '', id: 1 } }

      it 'returns Inventory::Entry::ResourceLink object' do
        expect(inventory_class).to be_a(Inventory::List::Entry::ResourceLink)
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
