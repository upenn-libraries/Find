# frozen_string_literal: true

describe AdditionalResults::AdditionalResultsComponent, type: :components do
  let(:trait) { nil }

  let(:component) do
    comp = build(:additional_results_component, trait)
    allow(comp).to receive(:valid?).and_return(true)
    comp
  end

  let(:rendered) { render_inline(component) }

  describe '#render?' do
    context 'when query is present and no sources are excluded' do
      it 'renders the component' do
        expect(rendered).to have_css('div.documents-list')
      end
    end

    context 'when query is present and some sources are excluded' do
      let(:trait) { :with_some_sources_excluded }

      it 'renders the component' do
        expect(rendered).to have_css('div.documents-list')
      end
    end

    context 'when query is missing' do
      let(:trait) { :without_query }

      it 'does not render the component' do
        expect(rendered.to_html).to be_empty
      end
    end

    context 'when all sources are generally excluded' do
      let(:trait) { :with_all_sources_generally_excluded }

      it 'does not render the component' do
        expect(rendered.to_html).to be_empty
      end
    end

    context 'when all sources are explicitly excluded' do
      let(:trait) { :with_all_sources_explicitly_excluded }

      it 'does not render the component' do
        expect(rendered.to_html).to be_empty
      end
    end
  end

  describe '#filtered_sources' do
    let(:filtered) { component.send(:filtered_sources) }

    context 'when no sources are excluded' do
      it 'returns all sources' do
        expect(filtered.size).to eq(3)
      end

      it 'renders turbo frame tags for all sources' do
        filtered.each do |source|
          expect(rendered).to have_css("turbo-frame##{source}-frame")
        end
      end
    end

    context 'when some sources are excluded' do
      let(:trait) { :with_some_sources_excluded }

      it 'returns the remaining sources' do
        expect(filtered.size).to eq(2)
      end

      it 'renders turbo frame tags for the remaining sources' do
        filtered.each do |source|
          expect(rendered).to have_css("turbo-frame##{source}-frame")
        end
      end
    end

    context 'when all sources are generally excluded' do
      let(:trait) { :with_all_sources_generally_excluded }

      it 'does not return any sources' do
        expect(filtered.size).to eq(0)
      end
    end

    context 'when all sources are explicitly excluded' do
      let(:trait) { :with_all_sources_explicitly_excluded }

      it 'does not return any sources' do
        expect(filtered.size).to eq(0)
      end
    end
  end
end
