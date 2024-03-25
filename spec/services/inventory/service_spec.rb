# frozen_string_literal: true

describe Inventory::Service do
  describe '.all' do
    let(:response) { described_class.all(document) }

    # mock Alma API gem behavior for physical inventory lookups
    # TODO: add to a shared context? could be useful in future specs
    before do
      # stub Alma API gem availability response to return a double
      availability_double = instance_double(Alma::AvailabilityResponse)
      allow(Alma::Bib).to receive(:get_availability).and_return(availability_double)
      # stub response double to return the availability data we want it to
      allow(availability_double).to receive(:availability).and_return(availability_data)
    end

    context 'with a record having Physical inventory' do
      let(:document) { SolrDocument.new({ id: '9979338417503681' }) }
      let(:availability_data) do
        { '9979338417503681' => { holdings: [build(:physical_availability_data)] } }
      end
      let(:item_data) do
        { 'physical_material_type' => { 'value' => 'BOOK', 'desc' => 'Book' },
          'policy' => { 'value' => 'book/seria', 'desc' => 'Book/serial' } }
      end

      before do
        # stub Alma API gem item lookup to return a double for an Alma::BibItemSet
        bib_item_set_double = instance_double(Alma::BibItemSet)
        allow(Alma::BibItem).to receive(:find).and_return(bib_item_set_double)
        bib_item_double = instance_double(Alma::BibItem)
        # stub the set to return our item double
        allow(bib_item_set_double).to receive(:items).and_return([bib_item_double])
        # stub the item_data for the Alma::BibItem object
        allow(bib_item_double).to receive(:item_data).and_return(item_data)
      end

      it 'returns a Inventory::Response object' do
        expect(response).to be_a Inventory::Response
      end

      it 'iterates over returned entries' do
        expect(response.first).to be_a Inventory::Entry
      end
    end

    context 'with a record having Electronic inventory' do
      let(:document) { SolrDocument.new({ id: '9977568423203681' }) }
      let(:availability_data) do
        { '9977568423203681' => { holdings: [build(:electronic_availability_data),
                                             build(:electronic_availability_data, :unavailable)] } }
      end

      it 'does not include unavailable entries' do
        expect(
          response.collect(&:status)
        ).not_to include Inventory::Constants::ELEC_UNAVAILABLE
      end
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

    context 'with resource link inventory type' do
      let(:data) { { inventory_type: Inventory::Entry::RESOURCE_LINK, href: '', description: '', id: 1 } }

      it 'returns Inventory::Entry::Electronic object' do
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
