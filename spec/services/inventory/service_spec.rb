# frozen_string_literal: true

describe Inventory::Service do
  # Mock Alma API gem behavior for physical inventory lookups.
  # TODO: share this context among other specs?
  shared_context 'with mocked Alma availability requests' do
    let(:availability_data) do
      base_holding = { 'holding_id' => '22810131440003681',
                       'institution' => '01UPENN_INST',
                       'library_code' => 'VanPeltLib',
                       'location' => 'Stacks',
                       'call_number' => 'HQ801 .D43 1997',
                       'availability' => Inventory::Constants::AVAILABLE,
                       'total_items' => '1',
                       'non_available_items' => '0',
                       'location_code' => 'vanp',
                       'call_number_type' => '0',
                       'priority' => '1',
                       'library' => 'Van Pelt Library',
                       'inventory_type' => Inventory::Entry::PHYSICAL }

      holdings = (1..4).map do |i|
        base_holding.dup.tap do |h|
          h['holding_id'] = i
          h['call_number'] = "#{h['call_number']} copy i"
        end
      end

      { mms_id => { holdings: holdings } }
    end
    let(:item_data) do
      { 'physical_material_type' => { 'value' => 'BOOK', 'desc' => 'Book' },
        'policy' => { 'value' => 'book/seria', 'desc' => 'Book/serial' } }
    end

    before do
      # stub Alma API gem availability response to return a double
      availability_double = instance_double(Alma::AvailabilityResponse)
      allow(Alma::Bib).to receive(:get_availability).and_return(availability_double)
      # stub response double to return the availability data we want it to
      allow(availability_double).to receive(:availability).and_return(availability_data)

      # stub Alma API gem item lookup to return a double for an Alma::BibItemSet
      bib_item_set_double = instance_double(Alma::BibItemSet)
      allow(Alma::BibItem).to receive(:find).and_return(bib_item_set_double)
      bib_item_double = instance_double(Alma::BibItem)
      # stub the set to return our item double
      allow(bib_item_set_double).to receive(:items).and_return([bib_item_double])
      # stub the item_data for the Alma::BibItem object
      allow(bib_item_double).to receive(:item_data).and_return(item_data)
    end
  end

  describe '.full' do
    include_context 'with mocked Alma availability requests'

    let(:mms_id) { '9979338417503681' }
    let(:document) { SolrDocument.new({ id: mms_id }) }
    let(:response) { described_class.full(document) }

    it 'returns a Inventory::Response object' do
      expect(response).to be_a Inventory::Response
    end

    it 'iterates over returned entries' do
      expect(response.first).to be_a Inventory::Entry
    end

    it 'returns all entries' do
      expect(response.count).to be 4
    end
  end

  describe '.brief' do
    include_context 'with mocked Alma availability requests'

    let(:mms_id) { '9979338417503681' }
    let(:document) { SolrDocument.new({ id: mms_id }) }
    let(:response) { described_class.brief(document) }

    # Mocking resource links.
    before do
      allow(document).to receive(:marc_resource_links).and_return(
        [{ link_text: 'Intro', link_url: "http://book.com/intro" },
         { link_text: 'Part 1', link_url: "http://book.com/part1" },
         { link_text: 'Part 2', link_url: "http://book.com/part2" }]
      )
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
      expect(response.select { |e| e.physical? }.count).to be Inventory::Service::DEFAULT_LIMIT

    end

    it 'returns only 2 resource links' do
      expect(response.select { |e| e.resource_link? }.count).to be Inventory::Service::RESOURCE_LINK_LIMIT
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
