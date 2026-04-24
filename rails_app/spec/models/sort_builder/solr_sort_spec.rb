# frozen_string_literal: true

describe SortBuilder::SolrSort do
  let(:solr_sort) { described_class }

  describe '.compose' do
    it 'joins an array of sort orderings' do
      orderings = ['score asc', 'title_sort asc', 'updated_date_sort desc']
      expect(solr_sort.compose(orderings)).to eq 'score asc,title_sort asc,updated_date_sort desc'
    end

    it 'handles an arbitrary number of sort ordering parameters' do
      expect(solr_sort.compose('score desc',
                               'title_sort asc',
                               'updated_date_sort desc')).to eq('score desc,title_sort asc,updated_date_sort desc')
    end
  end

  describe '.ascending' do
    it 'returns an ascending sort ordering' do
      expect(solr_sort.ascending(:score)).to eq 'score asc'
    end
  end

  describe '.descending' do
    it 'returns an descending sort ordering' do
      expect(solr_sort.descending(:score)).to eq 'score desc'
    end
  end

  describe '.term_boost' do
    it 'returns a function query that results in a boost based on whether a term is present in a field' do
      sort = 'if(termfreq(format_facet,Book),2,1)'
      expect(solr_sort.term_boost(field: :format_facet, value: 'Book', boost: 2, default_boost: 1)).to eq sort
    end
  end

  describe '.boosted_field_score' do
    it 'returns a function query that combines a term-based boost with a minimum field count score' do
      sort = 'sum(if(termfreq(language_facet,french),2,1),min(physical_holding_count_i,10))'
      expect(solr_sort.boosted_field_score(field: :physical_holding_count_i, term_boost_field: :language_facet,
                                           term_value: 'french', term_boost: 2, default_term_boost: 1)).to eq sort
    end
  end

  describe '.max_score' do
    it 'returns a function query that returns the higher of two scores' do
      expect(solr_sort.max_score('3', '2')).to eq 'max(3,2)'
    end
  end

  describe '.min_field_score' do
    it 'returns a function query that returns a field count capped at an upper limit' do
      expect(solr_sort.min_field_score(field: :physical_holding_count_i,
                                       limit: 5)).to eq 'min(physical_holding_count_i,5)'
    end
  end
end
