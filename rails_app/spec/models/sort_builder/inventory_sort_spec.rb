# frozen_string_literal: true

describe SortBuilder::InventorySort do
  let(:primary) { :electronic_portfolio_count_i }
  let(:secondary) { :physical_holding_count_i }
  let(:inventory_sort) { described_class.new(primary_inventory: primary, secondary_inventory: secondary) }

  describe '#enriched_relevance_sort' do
    sort = <<~SOLR_SORT.delete("\n")
      score desc,
      publication_date_sort desc,
      sum(if(termfreq(format_facet,Journal/Periodical),1,0),min(electronic_portfolio_count_i,10)) desc,
      min(physical_holding_count_i,10) desc,
      updated_date_sort desc
    SOLR_SORT
    it 'prioritizes the primary inventory field in the sort tie-breaker' do
      expect(inventory_sort.enriched_relevance_sort).to eq sort
    end
  end

  describe '#browse_sort' do
    it 'prioritizes primary inventory' do
      sort = 'min(electronic_portfolio_count_i,1) desc,encoding_level_sort asc,updated_date_sort desc'
      expect(inventory_sort.browse_sort).to eq sort
    end
  end
end
