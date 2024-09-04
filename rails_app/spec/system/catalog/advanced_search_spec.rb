# frozen_string_literal: true

require 'system_helper'

describe 'Advanced Search Page' do
  include Articles::ApiMocks::Search

  include_context 'with print monograph record with 2 physical entries'
  include_context 'with electronic journal record with 4 electronic entries'

  before { visit advanced_search_catalog_path }

  context 'when filtering with facets' do
    before do
      click_on 'Library'
      find('div.library_facet-select').click
    end

    it 'does not limit values' do
      within('div.ts-dropdown-content') { expect(page).to have_selector 'div', count: 11 }
    end

    it 'applies selected facets' do
      within('div.ts-dropdown-content') { find('div', text: /LIBRA/).click }
      click_on 'Search'
      within('#appliedParams') { expect(page).to have_text('LIBRA') }
    end
  end

  context 'when submitting blank search fields' do
    context 'with all search fields blank' do
      it 'makes the request to the expected path' do
        click_on 'Search'
        expect(page).to have_current_path '/?op=must&clause%5B0%5D%5Bfield%5D=all_fields_advanced'\
                                            '&clause%5B0%5D%5Bquery%5D=&'\
                                            'sort=score+desc%2C+publication_date_sort+desc%2C+title_sort+asc'\
                                            '&commit=Search'
      end
    end

    context 'with some search fields blank' do
      before do
        fill_in 'Title', with: 'Hypothalamus'
        click_on 'Search'
      end

      it 'makes the request to the expected path' do
        expect(page).to have_current_path '/?op=must&clause%5B0%5D%5Bfield%5D=all_fields_advanced'\
                                            '&clause%5B0%5D%5Bquery%5D=&clause%5B2%5D%5Bfield%5D=title_search'\
                                            '&clause%5B2%5D%5Bquery%5D=Hypothalamus'\
                                            '&sort=score+desc%2C+publication_date_sort+desc%2C+title_sort+asc'\
                                            '&commit=Search'
      end
    end
  end

  context 'when using a range search field' do
    context 'when submitting a ranged search with both endpoints' do
      before do
        from = find('legend', text: I18n.t('advanced.publication_date_search'))
               .sibling('.col-sm-9').find_field(I18n.t('advanced.range_labels.start'))
        to = find('legend', text: I18n.t('advanced.publication_date_search'))
             .sibling('.col-sm-9').find_field(I18n.t('advanced.range_labels.end'))
        from.fill_in with: '1865'
        to.fill_in with: '1965'
        click_on 'Search'
      end

      it 'submits the expected range search query' do
        expect(page).to have_selector 'article.document', count: 2
      end

      it 'displays the query constraint' do
        within('#appliedParams') do
          expect(page).to have_text("#{I18n.t('advanced.publication_date_search')} [1865 TO 1965]")
        end
      end
    end

    context 'when submitting a ranged search with only a starting point' do
      before do
        from = find('legend', text: I18n.t('advanced.publication_date_search'))
               .sibling('.col-sm-9').find_field(I18n.t('advanced.range_labels.start'))
        from.fill_in with: '1900'
        click_on 'Search'
      end

      it 'submits the expected range search query' do
        expect(page).to have_selector 'article.document', count: 1
        expect(page).to have_selector "article.document[data-document-id=\"#{print_monograph_bib}\"]", count: 1
      end

      it 'displays the query constraint' do
        within('#appliedParams') do
          expect(page).to have_text("#{I18n.t('advanced.publication_date_search')} [1900 TO *]")
        end
      end
    end

    context 'when submitting a ranged search with only an ending point' do
      before do
        to = find('legend', text: I18n.t('advanced.publication_date_search'))
             .sibling('.col-sm-9').find_field(I18n.t('advanced.range_labels.end'))
        to.fill_in with: '1900'
        click_on 'Search'
      end

      it 'submits the expected range search query' do
        expect(page).to have_selector 'article.document', count: 1
        expect(page).to have_selector "article.document[data-document-id=\"#{electronic_journal_bib}\"]", count: 1
      end

      it 'displays the query constraint' do
        within('#appliedParams') do
          expect(page).to have_text("#{I18n.t('advanced.publication_date_search')} [* TO 1900]")
        end
      end
    end

    context 'when no endpoints are submitted' do
      before { click_on 'Search' }

      it 'submits the expected range search query' do
        expect(page).to have_selector 'article.document', count: 2
      end

      it 'does not display query constraint' do
        within('#appliedParams') do
          expect(page).not_to have_text(I18n.t('advanced.publication_date_search'))
        end
      end
    end

    context 'with incoming query parameters' do
      before do
        visit(
          "#{advanced_search_catalog_path}?op=must&clause[0][field]=publication_date_s&clause[0]query=[2000 TO 2020]"
        )
      end

      it 'populates the range search inputs' do
        range_control = find('legend', text: I18n.t('advanced.publication_date_search')).sibling('.col-sm-9')
        expect(range_control).to have_field(I18n.t('advanced.range_labels.start'), with: '2000')
        expect(range_control).to have_field(I18n.t('advanced.range_labels.end'), with: '2020')
      end
    end

    context 'with additional search fields' do
      before do
        from = find('legend', text: I18n.t('advanced.publication_date_search'))
               .sibling('.col-sm-9').find_field(I18n.t('advanced.range_labels.start'))
        fill_in 'Subject', with: 'Cats'
        from.fill_in with: '1865'
        click_on 'Search'
      end

      it 'submits the expected range search query' do
        expect(page).to have_selector 'article.document', count: 1
        expect(page).to have_selector "article.document[data-document-id=\"#{print_monograph_bib}\"]", count: 1
      end
    end

    context 'with an invalid pattern' do
      it 'does not submit the form' do
        from = find('legend', text: I18n.t('advanced.publication_date_search'))
               .sibling('.col-sm-9').find_field(I18n.t('advanced.range_labels.start'))
        from.fill_in with: 'abcd'
        click_on 'Search'
        expect(page).to have_text('Advanced search')
      end
    end
  end

  context 'with incoming parameters' do
    let(:params) { {} }

    before do
      stub_summon_search_success(query: params[:q], fixture: 'book.json')
      visit search_catalog_path(params)
      click_on I18n.t('search.edit.label')
    end

    context 'with parameters included in the form' do
      let(:params) do
        { sort: 'creator_sort asc, title_sort asc', op: 'must',
          clause: { '4': { field: 'subject_search', query: 'Cats' },
                    '10': { field: 'place_of_publication_search', query: 'Baltimore' } },
          f_inclusive: { access_facet: ['At the library'] } }
      end

      it 'populates the search fields' do
        within('form.advanced') do
          expect(page).to have_field(I18n.t('advanced.subject_search'), with: 'Cats')
          expect(page).to have_field(I18n.t('advanced.place_of_publication_search'), with: 'Baltimore')
        end
      end

      it 'selects the facets' do
        within('form.advanced') do
          expect(page).to have_field('At the library', checked: true)
        end
      end

      it 'selects the sort order' do
        within('form.advanced') do
          expect(page).to have_select('sort', selected: I18n.t('sort.creator_asc'))
        end
      end
    end

    context 'with "q" parameter' do
      let(:params) { { q: 'keyword' } }

      it 'populates the keyword search field' do
        within('form.advanced') do
          expect(page).to have_field(I18n.t('advanced.all_fields'), with: params[:q])
        end
      end
    end

    context 'with "q" and keyword "clause" parameter' do
      let(:params) do
        { q: 'ignore',
          clause: { '0': { field: 'all_fields_advanced', query: 'prefer' } } }
      end

      it 'populates the keyword search field with the clause query parameter' do
        within('form.advanced') do
          expect(page).to have_field(I18n.t('advanced.all_fields'), with: params[:clause][:'0'][:query])
        end
      end
    end

    context 'with exclusive "f" facet parameter' do
      let(:params) { { f: { 'format_facet': ['Book'] } } }

      it 'does not select inclusive facet in multi select' do
        within('div.format_facet-select', visible: false) do
          expect(page).not_to have_text(params[:f][:format_facet].first)
        end
      end

      it 'does not activate the facet field component' do
        within('#advanced_search_facets') do
          expect(page).not_to have_css('div.blacklight-format_facet.facet-limit-active')
        end
      end

      it 'is displayed as a constraint' do
        within('.constraints') do
          expect(page).to have_text(params[:f][:format_facet].first)
        end
      end
    end
  end
end
