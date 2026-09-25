# frozen_string_literal: true

describe Catalog::SearchBarComponent, type: :components do
  let(:options) { {} }
  let(:rendered) do
    render_inline(described_class.new(url: '/catalog', params: ActionController::Parameters.new, **options))
  end
  let(:label) { I18n.t('blacklight.search.form.search.label') }

  it 'can be found by its label, and does not hide one behind an aria-label' do
    expect(rendered).to have_field(label)
    expect(rendered.css('input[type="search"]').first['aria-label']).to be_nil
  end

  it 'offers a submit button a person can name' do
    expect(rendered).to have_button(I18n.t('search.button.label'))
  end

  context 'with an id prefix' do
    let(:options) { { id_prefix: 'home_' } }

    it 'prefixes the ids, and the label still finds the field' do
      expect(rendered.css('input[type="search"]').first['id']).to eq 'home_query_input'
      expect(rendered).to have_field(label)
    end

    it 'leaves the query parameter alone, so the search still submits as q' do
      expect(rendered.css('input[type="search"]').first['name']).to eq 'q'
    end
  end
end
