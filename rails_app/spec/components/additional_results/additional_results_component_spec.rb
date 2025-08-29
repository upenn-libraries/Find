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
      it_behaves_like 'renders Additional Results component'
    end

    context 'when query is present and some sources are excluded' do
      let(:trait) { :with_some_sources_excluded }

      it_behaves_like 'renders Additional Results component'
    end

    context 'when query is missing' do
      let(:trait) { :without_query }

      it_behaves_like 'does not render Additional Results component'
    end

    context 'when all sources are generally excluded' do
      let(:trait) { :with_all_sources_generally_excluded }

      it_behaves_like 'does not render Additional Results component'
    end

    context 'when all sources are explicitly excluded' do
      let(:trait) { :with_all_sources_explicitly_excluded }

      it_behaves_like 'does not render Additional Results component'
    end
  end

  describe '#filtered_sources' do
    let(:filtered) { component.send(:filtered_sources) }

    context 'when no sources are excluded' do
      it_behaves_like 'returns expected number of included sources', 3
      it_behaves_like 'renders turbo frames for each included source'
    end

    context 'when some sources are excluded' do
      let(:trait) { :with_some_sources_excluded }

      it_behaves_like 'returns expected number of included sources', 2
      it_behaves_like 'renders turbo frames for each included source'
    end

    context 'when all sources are generally excluded' do
      let(:trait) { :with_all_sources_generally_excluded }

      it_behaves_like 'returns expected number of included sources', 0
    end

    context 'when all sources are explicitly excluded' do
      let(:trait) { :with_all_sources_explicitly_excluded }

      it_behaves_like 'returns expected number of included sources', 0
    end
  end
end
