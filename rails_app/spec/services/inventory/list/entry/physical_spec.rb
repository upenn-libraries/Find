# frozen_string_literal: true

describe Inventory::List::Entry::Physical do
  let(:mms_id) { '9979338417503681' }
  let(:entry) do
    create(
      :physical_entry,
      mms_id: mms_id,
      holding_id: '22810131440003681',
      holding_info: 'v1',
      total_items: '1',
      availability: Inventory::Constants::UNAVAILABLE
    )
  end
  let(:requested) { false }
  let(:item_data) do
    {
      'policy' => { 'desc' => 'Non-circ' },
      'physical_material_type' => { 'desc' => 'Book' },
      'requested' => requested
    }.compact
  end
  let(:items) do
    [Alma::BibItem.new('item_data' => item_data)]
  end

  def stub_alma_items(mms_id:, items:)
    bib_item_set = instance_double(Alma::BibItemSet, items: items)
    allow(Alma::BibItem).to receive(:find).with(mms_id, any_args).and_return(bib_item_set)
  end

  before do
    stub_alma_items(mms_id: mms_id, items: items)
  end

  describe '#status' do
    subject(:status) { entry.status }

    it 'is unavailable by default' do
      expect(status).to eq Inventory::Constants::UNAVAILABLE
    end

    context 'when the only item is requested' do
      let(:requested) { true }
      let(:entry) { create(:physical_entry, :single_item, :available, mms_id: mms_id) }

      it { is_expected.to eq Inventory::Constants::UNAVAILABLE }
    end

    context 'when one item is requested but others exist' do
      let(:requested) { true }
      let(:entry) { create(:physical_entry, :multiple_items, :available, mms_id: mms_id) }

      it { is_expected.to eq Inventory::Constants::AVAILABLE }
    end
  end

  describe '#policy' do
    it 'returns the item policy' do
      expect(entry.policy).to eq 'Non-circ'
    end
  end

  describe '#format' do
    it 'returns the physical material type' do
      expect(entry.format).to eq 'Book'
    end
  end

  describe '#coverage_statement' do
    it 'returns the holding info' do
      expect(entry.coverage_statement).to eq 'v1'
    end
  end

  describe '#count' do
    it 'returns the total item count' do
      expect(entry.count).to eq '1'
    end
  end

  describe '#id' do
    it 'returns the holding id' do
      expect(entry.id).to eq '22810131440003681'
    end
  end

  describe '#description' do
    it 'returns the call number' do
      expect(entry.description).to eq entry.data[:call_number]
    end
  end

  describe '#href' do
    it 'returns the expected path' do
      expect(entry.href).to eq(
        Rails.application.routes.url_helpers.solr_document_path(
          mms_id,
          hld_id: entry.id
        )
      )
    end
  end

  describe '#human_readable_location' do
    it 'returns mapped location name' do
      location_code = entry.data[:location_code].to_sym
      expect(entry.human_readable_location)
        .to eq Mappings.locations[location_code][:display]
    end

    context 'with a location override' do
      let(:entry) do
        build(
          :physical_entry,
          location_code: 'vanp',
          call_number: 'ML3534 .D85 1984',
          call_number_type: PennMARC::Classification::LOC_CALL_NUMBER_TYPE
        )
      end

      it 'returns the override location name' do
        expect(entry.human_readable_location)
          .to eq Mappings.location_overrides[:albrecht][:specific_location]
      end
    end
  end

  describe '#location' do
    it 'returns an Inventory::Location' do
      expect(entry.location).to be_a Inventory::Location
    end

    it 'has the expected location code' do
      expect(entry.location.code).to eq entry.data[:location_code]
    end
  end

  describe 'type predicates' do
    it 'is physical' do
      expect(entry).to be_physical
    end

    it 'is not electronic' do
      expect(entry).not_to be_electronic
    end

    it 'is not a resource link' do
      expect(entry).not_to be_resource_link
    end
  end
end
