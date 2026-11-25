# frozen_string_literal: true

describe Catalog::AdvancedSearchFormComponent, type: :component do
  include ViewComponent::TestHelpers
  let(:component) { described_class.new(url: '/adv', response: response, params: params) }
  let(:response) do
    Blacklight::Solr::Response.new({ facet_counts: { facet_fields: { access_facet: { 'At the library' => 10 },
                                                                     format_facet: { 'Book' => 20 } } } }
                                     .with_indifferent_access, Blacklight::SearchBuilder.new(view_context))
  end
  let(:params) do
    { sort: 'creator_sort asc, title_sort asc', op: 'must',
      clause: { '4': { field: 'subject_search', query: 'Cats' },
                '10': { field: 'place_of_publication_search', query: 'Baltimore' } },
      f_inclusive: { access_facet: ['At the library'] },
      action: 'advanced_search' }.with_indifferent_access
  end
  let(:view_context) { vc_test_controller.view_context }
  let(:search_state) do
    Blacklight::SearchState.new(params, view_context.blacklight_config)
  end

  before do
    with_controller_class(CatalogController) do
      vc_test_controller.request.path_parameters[:controller] = 'catalog'
      allow(vc_test_controller).to receive_messages(view_context: view_context, search_state: search_state,
                                                    params: params)
      render_inline component
    end
  end

  context 'with parameters included in the form' do
    it 'populates the search fields' do
      expect(page).to have_field(I18n.t('advanced.subject_search'), with: 'Cats')
      expect(page).to have_field(I18n.t('advanced.place_of_publication_search'), with: 'Baltimore')
    end

    it 'selects the facets' do
      expect(page).to have_field('At the library', checked: true)
    end

    it 'selects the sort order' do
      expect(page).to have_select('sort', selected: I18n.t('sort.creator_asc'))
    end

    context 'with "q" parameter' do
      let(:params) { { q: 'keyword' } }

      it 'populates the keyword search field' do
        expect(page).to have_field(I18n.t('advanced.all_fields'), with: params[:q])
      end
    end

    context 'with "q" and keyword "clause" parameter' do
      let(:params) do
        { q: 'ignore', clause: { '0': { field: 'all_fields_advanced', query: 'prefer' } } }.with_indifferent_access
      end

      it 'populates the keyword search field with the clause query parameter' do
        expect(page).to have_field(I18n.t('advanced.all_fields'), with: params[:clause][:'0'][:query])
      end
    end

    context 'with exclusive "f" facet parameter' do
      let(:params) { { action: 'advanced_search', f: { 'format_facet': ['Book'] } } }

      it 'does not select inclusive facet in multi select' do
        expect(page).to have_select('f_inclusive[format_facet][]')
        expect(page).not_to have_select('f_inclusive[format_facet][]', selected: 'Book')
      end

      it 'does not activate the facet field component' do
        expect(page).not_to have_css('div.blacklight-format_facet.facet-limit-active')
      end

      it 'is displayed as a constraint' do
        expect(page).to have_text(params[:f][:format_facet].first)
      end
    end

    context 'with range parameters' do
      let(:params) do
        { action: 'advanced_search',
          clause: { '16': { field: 'publication_date_s', query: '[2000 TO 2020]' } } }.with_indifferent_access
      end

      it 'populates the range search inputs' do
        expect(page).to have_field(I18n.t('advanced.range_labels.start'), with: '2000')
        expect(page).to have_field(I18n.t('advanced.range_labels.end'), with: '2020')
      end
    end
  end
end
