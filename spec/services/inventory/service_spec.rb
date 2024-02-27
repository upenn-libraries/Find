# frozen_string_literal: true

describe Inventory::Service do
  let(:document) { SolrDocument.new({ id: '9979338417503681' }) }
  let(:availability_data) do
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

  let(:item_data) do
    { 'physical_material_type' => { 'value' => 'BOOK', 'desc' => 'Book' },
      'policy' => { 'value' => 'book/seria', 'desc' => 'Book/serial' } }
  end

  # mock Alma API gem behavior for physical inventory
  # TODO: add to a shared context? could be useful in future specs
  before do
    availability_double = instance_double(Alma::AvailabilityResponse)
    allow(Alma::Bib).to receive(:get_availability).and_return(availability_double)
    allow(availability_double).to receive(:availability).and_return(availability_data)
    bib_item_set_double = instance_double(Alma::BibItemSet)
    allow(Alma::BibItem).to receive(:find).and_return(bib_item_set_double)
    bib_item_double = instance_double(Alma::BibItem)
    allow(bib_item_set_double).to receive(:items).and_return([bib_item_double])
    allow(bib_item_double).to receive(:item_data).and_return(item_data)
  end

  describe '.all' do
    let(:response) { described_class.all(document) }

    it 'returns a Inventory::Response object' do
      expect(response).to be_a Inventory::Response
    end

    it 'returns expected entry values' do
      expect(response.entries.first.to_h).to eq({ count: '1', description: 'HQ801 .D43 1997', format: 'Book',
                                                  href: '/catalog/9979338417503681?hld_id=22810131440003681',
                                                  id: '22810131440003681', location: 'Van Pelt Library',
                                                  policy: 'Book/serial', status: 'available', type: 'physical' })
    end

    it 'returns a remainder' do
      expect(response.remainder).to be 0
    end
  end

  describe '.create_entries' do
    let(:inventory_class) { described_class.send(:create_entry, '9999999999', { inventory_type: type }) }

    context 'with physical inventory type' do
      let(:type) { Inventory::Entry::PHYSICAL }

      it 'returns Inventory::Entry::Physical object' do
        expect(inventory_class).to be_a(Inventory::Entry::Physical)
      end
    end

    context 'with electronic inventory type' do
      let(:type) { Inventory::Entry::ELECTRONIC }

      it 'returns Inventory::Entry::Electronic object' do
        expect(inventory_class).to be_a(Inventory::Entry::Electronic)
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
