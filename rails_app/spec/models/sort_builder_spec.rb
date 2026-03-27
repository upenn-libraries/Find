# frozen_string_literal: true

describe SortBuilder do
  let(:blacklight_params) { {} }
  let(:sort_builder) { described_class.new(blacklight_params) }
  let(:mock_sort) { nil }

  before do
    allow(SortBuilder::InventorySort).to receive(:new).and_return(mock_sort)
    allow(SortBuilder::DefaultSort).to receive(:new).and_return(mock_sort)

    allow(mock_sort).to receive_messages({ enriched_relevance_sort: 'mock_relevance_sort',
                                           browse_sort: 'mock_browse_sort' })
  end

  describe '.title_sort_asc' do
    it 'returns the expected sort value' do
      expect(described_class.title_sort_asc).to eq 'title_sort asc,publication_date_sort desc'
    end
  end

  describe '.relevance_sort' do
    it 'returns the expected sort value' do
      expect(described_class.relevance_sort).to eq 'score desc,publication_date_sort desc,title_sort asc'
    end
  end

  describe '#enriched_relevance_sort' do
    context 'with an "Online" access facet' do
      let(:mock_sort) { instance_double(SortBuilder::InventorySort) }
      let(:blacklight_params) { { f: { access_facet: [described_class::ONLINE_ACCESS] } } }

      it 'delegates to an InventorySort that prioritizes electronic inventory' do
        sort_builder.enriched_relevance_sort
        expect(SortBuilder::InventorySort).to have_received(:new)
          .with(primary_inventory: described_class::ELECTRONIC_INVENTORY_FIELD,
                secondary_inventory: described_class::PHYSICAL_INVENTORY_FIELD)
      end

      it 'returns the delegated sort value' do
        expect(sort_builder.enriched_relevance_sort).to eq 'mock_relevance_sort'
      end
    end

    context 'with an "At the library" access facet' do
      let(:mock_sort) { instance_double(SortBuilder::InventorySort) }
      let(:blacklight_params) { { f: { access_facet: [described_class::PHYSICAL_ACCESS] } } }

      it 'delegates to an InventorySort that prioritizes physical inventory' do
        sort_builder.enriched_relevance_sort
        expect(SortBuilder::InventorySort).to have_received(:new)
          .with(primary_inventory: described_class::PHYSICAL_INVENTORY_FIELD,
                secondary_inventory: described_class::ELECTRONIC_INVENTORY_FIELD)
      end

      it 'returns the delegated sort value' do
        expect(sort_builder.enriched_relevance_sort).to eq('mock_relevance_sort')
      end
    end

    context 'without an access facet' do
      let(:blacklight_sort) { instance_double(SortBuilder::DefaultSort) }

      it 'delegates to a DefaultSort' do
        sort_builder.enriched_relevance_sort
        expect(SortBuilder::DefaultSort).to have_received(:new)
      end

      it 'returns the delegated sort value' do
        expect(sort_builder.enriched_relevance_sort).to eq('mock_relevance_sort')
      end
    end
  end

  describe '#browse_sort' do
    context 'with an "Online" access facet' do
      let(:mock_sort) { instance_double(SortBuilder::InventorySort) }
      let(:blacklight_params) { { f: { access_facet: [described_class::ONLINE_ACCESS] } } }

      it 'delegates to an InventorySort that prioritizes electronic inventory' do
        sort_builder.browse_sort
        expect(SortBuilder::InventorySort).to have_received(:new)
          .with(primary_inventory: described_class::ELECTRONIC_INVENTORY_FIELD,
                secondary_inventory: described_class::PHYSICAL_INVENTORY_FIELD)
      end

      it 'returns the delegated sort value' do
        expect(sort_builder.browse_sort).to eq('mock_browse_sort')
      end
    end

    context 'with an "At the library" access facet' do
      let(:mock_sort) { instance_double(SortBuilder::InventorySort) }
      let(:blacklight_params) { { f: { access_facet: [described_class::PHYSICAL_ACCESS] } } }

      it 'delegates to an InventorySort that prioritizes physical inventory' do
        sort_builder.browse_sort
        expect(SortBuilder::InventorySort).to have_received(:new)
          .with(primary_inventory: described_class::PHYSICAL_INVENTORY_FIELD,
                secondary_inventory: described_class::ELECTRONIC_INVENTORY_FIELD)
      end

      it 'returns the delegated sort value' do
        expect(sort_builder.browse_sort).to eq('mock_browse_sort')
      end
    end

    context 'without an access facet' do
      let(:default_sort) { instance_double(SortBuilder::DefaultSort) }

      it 'delegates to a DefaultSort' do
        sort_builder.browse_sort
        expect(SortBuilder::DefaultSort).to have_received(:new)
      end

      it 'returns the delegated sort value' do
        expect(sort_builder.browse_sort).to eq('mock_browse_sort')
      end
    end
  end
end
