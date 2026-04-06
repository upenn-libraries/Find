# frozen_string_literal: true

describe Hathi::HathiComponent do
  let(:record) { {} }
  let(:component) { described_class.new(identifier_map: 'test') }

  before { allow(Hathi::Service).to receive(:record).and_return(record) }

  describe '#header' do
    context 'when at least one item has full viewability' do
      let(:record) { { 'records' => {}, 'items' => [{ 'usRightsString'=> described_class::FULL_VIEW }] } }

      it 'returns full viewability header' do
        expect(component.header).to eq I18n.t('inventory.hathi.header.full')
      end
    end

    context 'when no items have full viewability' do
      let(:record) { { 'records' => {}, 'items' => [{ 'usRightsString'=> 'Limited (search-only)' }] } }

      it 'returns the limited viewability header' do
        expect(component.header).to eq I18n.t('inventory.hathi.header.limited')
      end
    end
  end
end
