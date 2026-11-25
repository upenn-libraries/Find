# frozen_string_literal: true

require 'system_helper'

describe 'Advanced Search Page' do
  include Articles::ApiMocks::Search

  include_context 'with print monograph record with 2 physical entries'
  include_context 'with electronic journal record with 4 electronic entries'

  before { visit advanced_search_catalog_path }

  context 'when filtering with facets' do
    before do
      page.document.synchronize do
        click_on 'Library'
        find('div.library_facet-select').click
      end
    end

    it 'does not limit values' do
      within('div.ts-dropdown-content') { expect(page).to have_selector 'div', count: 4 }
    end

    it 'applies selected facets' do
      within('div.ts-dropdown-content') { find('div', text: /Health Sciences Libraries/).click }
      click_on 'Search'
      expect(page).to have_text('Health Sciences Libraries')
    end
  end

  context 'when submitting blank search fields' do
    context 'with all search fields blank' do
      it 'makes the request to the expected path' do
        click_on 'Search'
        expect(page).to have_current_path '/?op=must&clause%5B0%5D%5Bfield%5D=all_fields_advanced'\
                                            '&clause%5B0%5D%5Bquery%5D=&'\
                                            'sort=score+desc%2Cpublication_date_sort+desc%2Ctitle_sort+asc'\
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
                                            '&clause%5B2%5D%5Bquery%5D=Hypothalamus&'\
                                            'sort=score+desc%2Cpublication_date_sort+desc%2Ctitle_sort+asc'\
                                            '&commit=Search'
      end
    end
  end

  context 'when using a range search field' do
    context 'when submitting a ranged search with both endpoints' do
      before do
        page.document.synchronize do
          from = find('legend', text: I18n.t('advanced.publication_date_search'))
                 .sibling('.col-sm-9').find_field(I18n.t('advanced.range_labels.start'))
          to = find('legend', text: I18n.t('advanced.publication_date_search'))
               .sibling('.col-sm-9').find_field(I18n.t('advanced.range_labels.end'))
          from.fill_in with: '1865'
          to.fill_in with: '1965'
          click_on 'Search'
        end
      end

      it 'makes the request to the expected path' do
        expect(page).to have_current_path '/?op=must&clause%5B0%5D%5Bfield%5D=all_fields_advanced'\
                                            '&clause%5B0%5D%5Bquery%5D=&clause%5B16%5D%5Bfield%5D=publication_date_s'\
                                            '&clause%5B16%5D%5Bquery%5D=%5B1865+TO+1965%5D'\
                                            '&sort=score+desc%2Cpublication_date_sort+desc%2Ctitle_sort+asc'\
                                            '&commit=Search'
      end
    end

    context 'when submitting a ranged search with only a starting point' do
      before do
        page.document.synchronize do
          from = find('legend', text: I18n.t('advanced.publication_date_search'))
                 .sibling('.col-sm-9').find_field(I18n.t('advanced.range_labels.start'))
          from.fill_in with: '1900'
          click_on 'Search'
        end
      end

      it 'makes the request to the expected path' do
        expect(page).to have_current_path '/?op=must&clause%5B0%5D%5Bfield%5D=all_fields_advanced'\
                                            '&clause%5B0%5D%5Bquery%5D=&clause%5B16%5D%5Bfield%5D=publication_date_s'\
                                            '&clause%5B16%5D%5Bquery%5D=%5B1900+TO+*%5D'\
                                            '&sort=score+desc%2Cpublication_date_sort+desc%2Ctitle_sort+asc'\
                                            '&commit=Search'
      end
    end

    context 'when submitting a ranged search with only an ending point' do
      before do
        page.document.synchronize do
          to = find('legend', text: I18n.t('advanced.publication_date_search'))
               .sibling('.col-sm-9').find_field(I18n.t('advanced.range_labels.end'))
          to.fill_in with: '1900'
          click_on 'Search'
        end
      end

      it 'makes the request to the expected path' do
        expect(page).to have_current_path '/?op=must&clause%5B0%5D%5Bfield%5D=all_fields_advanced'\
                                            '&clause%5B0%5D%5Bquery%5D=&clause%5B16%5D%5Bfield%5D=publication_date_s'\
                                            '&clause%5B16%5D%5Bquery%5D=%5B*+TO+1900%5D'\
                                            '&sort=score+desc%2Cpublication_date_sort+desc%2Ctitle_sort+asc'\
                                            '&commit=Search'
      end
    end

    context 'when no endpoints are submitted' do
      before do
        click_on 'Search'
      end

      it 'makes the request to the expected path' do
        expect(page).to have_current_path '/?op=must&clause%5B0%5D%5Bfield%5D=all_fields_advanced'\
                                          '&clause%5B0%5D%5Bquery%5D='\
                                          '&sort=score+desc%2Cpublication_date_sort+desc%2Ctitle_sort+asc'\
                                          '&commit=Search'
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

      it 'makes the request to the expected path' do
        expect(page).to have_current_path '/?op=must&clause%5B0%5D%5Bfield%5D=all_fields_advanced'\
        '&clause%5B0%5D%5Bquery%5D=&clause%5B4%5D%5Bfield%5D=subject_search&clause%5B4%5D%5Bquery%5D=Cats'\
          '&clause%5B16%5D%5Bfield%5D=publication_date_s'\
        '&clause%5B16%5D%5Bquery%5D=%5B1865+TO+*%5D&sort=score+desc%2Cpublication_date_sort+desc%2Ctitle_sort+asc'\
                                          '&commit=Search'
      end
    end

    context 'with an invalid pattern' do
      it 'does not submit the form' do
        page.document.synchronize do
          find('legend', text: I18n.t('advanced.publication_date_search'))
            .sibling('.col-sm-9').find_field(I18n.t('advanced.range_labels.start'))
            .fill_in with: 'abcd'
          click_on 'Search'
        end
        expect(page).to have_current_path advanced_search_catalog_path
      end
    end
  end
end
