# frozen_string_literal: true

describe Inventory::List::Entry::Physical do
  let(:mms_id) { '9979338417503681' }
  let(:entry) do
    create(
      :physical_entry,
      mms_id: mms_id,
      holding_id: '22810131440003681',
      institution: '01UPENN_INST',
      library_code: 'VanPeltLib',
      location: 'Stacks',
      call_number: 'HQ801 .D43 1997',
      availability: Inventory::Constants::UNAVAILABLE,
      total_items: '1',
      non_available_items: '0',
      location_code: 'vanp',
      call_number_type: '0',
      priority: '1',
      holding_info: 'v1',
      library: 'Van Pelt Library',
      inventory_type: Inventory::List::PHYSICAL
    )
  end

  # Mocking response for items.
  let(:item_data) { { 'policy' => { 'desc' => 'Non-circ' }, 'physical_material_type' => { 'desc' => 'Book' } } }

  before do
    bib_item_set = instance_double(Alma::BibItemSet)
    allow(bib_item_set).to receive(:items).and_return(
      [
        Alma::BibItem.new({ 'item_data' => item_data })
      ]
    )
    allow(Alma::BibItem).to receive(:find).with(mms_id, any_args).and_return(bib_item_set)
  end

  describe '#status' do
    it 'returns expected status' do
      expect(entry.status).to eq Inventory::Constants::UNAVAILABLE
    end

    context 'with one requested item' do
      let(:item_data) do
        { 'policy' => { 'desc' => 'Non-circ' }, 'physical_material_type' => { 'desc' => 'Book' }, 'requested' => true }
      end

      it 'returns unavailable' do
        entry.data[:availability] = Inventory::Constants::AVAILABLE
        entry.data[:total_items] = '1'
        expect(entry.status).to eq Inventory::Constants::UNAVAILABLE
      end
    end

    context 'with one requested item and other items' do
      let(:item_data) do
        { 'policy' => { 'desc' => 'Non-circ' }, 'physical_material_type' => { 'desc' => 'Book' }, 'requested' => true }
      end

      it 'returns available' do
        entry.data[:availability] = Inventory::Constants::AVAILABLE
        entry.data[:total_items] = '2'
        expect(entry.status).to eq Inventory::Constants::AVAILABLE
      end
    end
  end

  describe '#human_readable_status' do
    it 'returns expected human_readable_status' do
      expect(entry.human_readable_status).to eq I18n.t('alma.availability.physical.unavailable.label')
    end
  end

  describe '#policy' do
    it 'returns expected policy' do
      expect(entry.policy).to eql 'Non-circ'
    end
  end

  describe '#description' do
    it 'returns expected description' do
      expect(entry.description).to eql 'HQ801 .D43 1997'
    end
  end

  describe '#href' do
    it 'returns the expected path' do
      expect(entry.href).to eq Rails.application.routes.url_helpers.solr_document_path(mms_id, hld_id: entry.id)
    end
  end

  describe '#id' do
    it 'returns the expected id' do
      expect(entry.id).to eq '22810131440003681'
    end
  end

  describe '#format' do
    it 'returns the expected format' do
      expect(entry.format).to eq 'Book'
    end
  end

  describe '#coverage_statement' do
    it 'returns expected value' do
      expect(entry.coverage_statement).to eql 'v1'
    end
  end

  describe '#count' do
    it 'returns the expected count' do
      expect(entry.count).to eql '1'
    end
  end

  describe '#human_readable_location' do
    it 'returns expected value' do
      location_code = entry.data[:location_code].to_sym
      expect(entry.human_readable_location).to eq Mappings.locations[location_code][:display]
    end

    context 'with a location override' do
      let(:entry) do
        build(:physical_entry, location_code: 'vanp', call_number: 'ML3534 .D85 1984',
                               call_number_type: PennMARC::Classification::LOC_CALL_NUMBER_TYPE)
      end

      it 'returns expected name' do
        expect(entry.human_readable_location).to eq(Mappings.location_overrides[:albrecht][:specific_location])
      end
    end
  end

  describe '#location' do
    it 'returns Inventory::Location' do
      expect(entry.location).to be_a Inventory::Location
      expect(entry.location.code).to eql entry.data[:location_code]
    end
  end

  describe '#electronic?' do
    it 'returns false' do
      expect(entry.electronic?).to be false
    end
  end

  describe '#physical?' do
    it 'returns true' do
      expect(entry.physical?).to be true
    end
  end

  describe '#resource_link?' do
    it 'returns false' do
      expect(entry.resource_link?).to be false
    end
  end
end
