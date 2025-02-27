# frozen_string_literal: true

require 'system_helper'

describe 'Discover Penn page' do
  include Discover::ApiMocks::Request
  include FixtureHelpers

  before { visit discover_path }

  context 'when submitting a query with results' do
    let(:query) { { q: 'test' } }

    before do
      stub_all_responses(query: query)
      fill_in 'q', with: query[:q]
      click_on I18n.t('discover.search.button.label')
    end

    context 'with libraries results' do
      it 'displays the expected icon' do
        within('#libraries') { expect(page).to have_css('i.bi.bi-book') }
      end

      it 'links to all results' do
        within('#libraries div.card-header') do
          expect(page).to have_link(I18n.t('discover.results.view_all_button.label', count: 1),
                                    href: 'https://find.library.upenn.edu/?f%5Baccess_facet%5D%5B%5D=' \
          "At+the+library\u0026f%5Blibrary_facet%5D%5B%5D=Special+Collections\u0026q=%22Menil+%3A+the+Menil" \
                                      "+collection%22\u0026search_field=all_fields".squish,
                                    exact: true)
        end
      end

      it 'links to the record' do
        within '#libraries h3.results-list-item__heading' do
          expect(page).to have_link('Menil : the Menil collection',
                                    href: 'https://find.library.upenn.edu/catalog/9960586893503681',
                                    exact: true)
        end
      end

      it 'displays author' do
        within '#libraries dl.results-list-item__metadata' do
          expect(page).to have_text('Piano, Renzo.')
        end
      end

      it 'displays format' do
        within '#libraries dl.results-list-item__metadata' do
          expect(page).to have_text('Book')
        end
      end

      it 'displays publication' do
        within '#libraries dl.results-list-item__metadata' do
          expect(page).to have_text(<<~TEXT.squish)
            [Genova] : Fondazione Renzo Piano ;
            [Place of publication not identified] : SOFP,
            Società operativa Fondazione Piano srl, [2007]
          TEXT
        end
      end

      it 'displays location' do
        within '#libraries dl.results-list-item__metadata dd.results-list-item__location' do
          expect(page).to have_text('Fisher Fine Arts Library, Special Collections')
        end
      end

      it 'displays the total count in the overview area' do
        within '#find-results-count' do
          expect(page).to have_text '(1)'
        end
      end
    end

    context 'with archives results' do
      it 'displays the expected icon' do
        within('#archives') { expect(page).to have_css('i.bi.bi-archive') }
      end

      it 'links to all results' do
        within('#archives div.card-header') do
          expect(page).to have_link(I18n.t('discover.results.view_all_button.label', count: 1),
                                    href: 'https://findingaids.library.upenn.edu/?f%5B' \
                                    "record_source%5D%5B%5D=upenn\u0026q=shainswit",
                                    exact: true)
        end
      end

      it 'links to the record' do
        within '#archives h3.results-list-item__heading' do
          expect(page).to have_link('Kronish, Lieb, Weiner, and Hellman LLP Bankruptcy Judges Lawsuit files',
                                    href: 'https://findingaids.library.upenn.edu/records/UPENN_BIDDLE_PU-L.NBA.027',
                                    exact: true)
        end
      end

      it 'displays creator' do
        within '#archives dl.results-list-item__metadata' do
          expect(page).to have_text('Kronish, Lieb, Weiner, and Hellman LLP, National Bankruptcy Archives')
        end
      end

      it 'displays format' do
        within '#archives dl.results-list-item__metadata' do
          expect(page).to have_text('Legal files')
        end
      end

      it 'displays abstract' do
        within '#archives dl.results-list-item__metadata' do
          expect(page).to have_text(/On July 11, 1984, William Foley, Legislative Affairs Officer/)
        end
      end

      it 'displays location' do
        within '#archives dl.results-list-item__metadata dd.results-list-item__location' do
          expect(page).to have_text('University of Pennsylvania: Biddle Law Library')
        end
      end

      it 'displays the total count in the overview area' do
        within '#finding_aids-results-count' do
          expect(page).to have_text '(1)'
        end
      end
    end

    context 'with museum results' do
      it 'displays the expected icon' do
        within('#penn-museum') { expect(page).to have_css('i.card-icon.discover-icon.discover-icon-museum') }
      end

      it 'links to all results' do
        within('#penn-museum div.card-header') do
          expect(page).to have_link(I18n.t('discover.results.view_all_button.label', count: 1),
                                    href: "https://www.penn.museum/collections/search.php?term=#{query[:q]}",
                                    exact: true)
        end
      end

      it 'links to the item' do
        within '#penn-museum h3.results-list-item__heading' do
          expect(page).to have_link('Hebrew Bowl - B13186',
                                    href: 'https://www.penn.museum/collections/object/297737',
                                    exact: true)
        end
      end

      it 'displays snippet' do
        within '#penn-museum dl.results-list-item__metadata' do
          expect(page).to have_text('Penn Museum Object B13186 - Hebrew Bowl.')
        end
      end

      it 'displays location' do
        within '#penn-museum dl.results-list-item__metadata dd.results-list-item__location' do
          expect(page).to have_text('Collections - Penn Museum')
        end
      end

      it 'displays the thumbnail' do
        within '#penn-museum' do
          image = find('img.results-list-item__thumbnail')
          expect(image[:src]).to include('https://encrypted-tbn0.gstatic.com/images?' \
                                           'q=tbn:ANd9GcTJ0lINTS91fxglgMk3xdtNon48uYwyecwIDr7yrB6MNeKV8DaaJDvbTa0Z&s')
        end
      end

      it 'displays the total count in the overview area' do
        within '#museum-results-count' do
          expect(page).to have_text '(1)'
        end
      end
    end

    context 'with art collection results' do
      it 'displays the expected icon' do
        within('#penn-art-collection') { expect(page).to have_css('i.bi.bi-brush') }
      end

      it 'links to all results' do
        within('#penn-art-collection div.card-header') do
          expect(page).to have_link(I18n.t('discover.results.view_all_button.label', count: 1),
                                    href: "https://pennartcollection.com/?s=#{query[:q]}",
                                    exact: true)
        end
      end

      it 'links to the item' do
        within '#penn-art-collection h3.results-list-item__heading' do
          expect(page).to have_link("Leonardo's Lady",
                                    href: 'https://pennartcollection.com/collection/art/194/leonardos-lady/',
                                    exact: true)
        end
      end

      it 'displays snippet' do
        within '#penn-art-collection dl.results-list-item__metadata' do
          expect(page).to have_text(/... Photorealism, becoming one of the pioneering artists in the genre./)
        end
      end

      it 'displays the thumbnail' do
        within '#penn-art-collection' do
          image = find('img.results-list-item__thumbnail')
          expect(image[:src]).to include('https://encrypted-tbn0.gstatic.com/images?q=' \
                                         'tbn:ANd9GcRCUpKWXMJZ1VIqw7H1RcnzcTFt44CGMyR_kRVMlrkz5MdtMhW7UyBCG-g&s')
        end
      end

      it 'displays the total count in the overview area' do
        within '#art_collection-results-count' do
          expect(page).to have_text '(1)'
        end
      end
    end
  end

  context 'when submitting a query with no results from a source' do
    context 'with no results from a source' do
      let(:query) { { q: 'test' } }

      before do
        stub_all_responses(query: query, except: :find)
        stub_empty_find_response query: query
        fill_in 'q', with: query[:q]
        click_on I18n.t('discover.search.button.label')
      end

      it 'displays expected message' do
        within('#libraries') do
          expect(page).to have_text(I18n.t('discover.results.messages.no_results'))
        end
      end
    end
  end
end
