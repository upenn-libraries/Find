# frozen_string_literal: true

describe Catalog::SearchBarComponent, type: :components do
  let(:options) { {} }
  let(:rendered) do
    render_inline(described_class.new(url: '/catalog', params: ActionController::Parameters.new, **options))
  end
  let(:input) { rendered.css('input[type="search"]').first }

  it 'names the field with a real label rather than an aria-label' do
    expect(input['aria-label']).to be_nil
    expect(rendered.css("label[for=\"#{input['id']}\"]")).to be_present
  end

  context 'with an id prefix, as the home page uses so two search boxes can coexist' do
    let(:options) { { id_prefix: 'home_' } }

    it 'prefixes the field id' do
      expect(input['id']).to eq 'home_query_input'
    end

    it 'keeps the label and the autocomplete pointing at the prefixed field' do
      expect(rendered.css('label[for="home_query_input"]')).to be_present
      expect(rendered.css('pennlibs-autocomplete').first['for']).to eq 'home_query_input'
    end

    # id_prefix is deliberately separate from prefix, which form_with uses as the field scope
    it 'leaves the query parameter alone, so the search still submits as q' do
      expect(input['name']).to eq 'q'
    end
  end
end
