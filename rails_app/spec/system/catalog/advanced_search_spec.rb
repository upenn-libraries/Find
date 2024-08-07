# frozen_string_literal: true

require 'system_helper'

describe 'Advanced Search Page' do
  include_context 'with print monograph record with 2 physical entries'
  include_context 'with electronic journal record with 4 electronic entries'

  before { visit advanced_search_catalog_path }

  context 'when submitting blank search fields' do
    context 'with all search fields blank' do
      it 'makes the request to the expected path' do
        click_on 'Search'
        expect(page).to have_current_path '/?op=must&clause%5B0%5D%5Bfield%5D=all_fields_advanced'\
                                            '&clause%5B0%5D%5Bquery%5D=&sort=score+desc&commit=Search'
      end
    end

    context 'with some search fields blank' do
      before do
        fill_in 'Subject', with: 'Cats'
        fill_in 'Title', with: 'Hypothalamus'
        click_on 'Search'
      end

      it 'makes the request to the expected path' do
        expect(page).to have_current_path '/?op=must&clause%5B0%5D%5Bfield%5D=all_fields_advanced'\
                                            '&clause%5B0%5D%5Bquery%5D=&clause%5B2%5D%5Bfield%5D=title_search'\
                                            '&clause%5B2%5D%5Bquery%5D=Hypothalamus'\
                                            '&clause%5B4%5D%5Bfield%5D=subject_search&clause%5B4%5D%5Bquery%5D=Cats'\
                                            '&sort=score+desc&commit=Search'
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
end
