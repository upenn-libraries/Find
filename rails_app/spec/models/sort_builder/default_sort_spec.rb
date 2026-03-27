# frozen_string_literal: true

describe SortBuilder::DefaultSort do
  let(:default_sort) { described_class.new }

  describe '#enriched_relevance_sort' do
    it 'prioritizes by the highest journal boosted inventory scores, slightly favoring electronic inventory' do
      sort = <<~SOLR_SORT.delete("\n")
        score desc,
        publication_date_sort desc,
        max(sum(if(termfreq(format_facet,'Journal/Periodical'),2,0),min(physical_holding_count_i,10)),
        sum(if(termfreq(format_facet,'Journal/Periodical'),3,1),min(electronic_portfolio_count_i,10))) desc,
        updated_date_sort desc
      SOLR_SORT
      expect(default_sort.enriched_relevance_sort).to eq sort
    end
  end

  describe '#browse_sort' do
    it 'prioritizes well encoded records and disregards inventory' do
      expect(default_sort.browse_sort).to eq 'encoding_level_sort asc,updated_date_sort desc'
    end
  end
end
