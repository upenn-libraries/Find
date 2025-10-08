# frozen_string_literal: true

describe Catalog::FacetLinkComponent do
  let(:field) { instance_double Blacklight::FieldPresenter, field_config: field_config, values: values }
  let(:field_config) { OpenStruct.new(limit: limit) }
  let(:component) { described_class.new(field: field) }

  describe '#truncate_values_list?' do
    context 'when the field configuration includes a limit value less than the number of values' do
      let(:limit) { 1 }
      let(:values) { %w[a b c] }

      it 'return true' do
        expect(component.truncate_values_list?).to be true
      end
    end

    context 'when the field configuration includes a limit value equal to the number of values' do
      let(:limit) { 2 }
      let(:values) { %w[a b] }

      it 'return true' do
        expect(component.truncate_values_list?).to be false
      end
    end

    context 'when the field configuration includes a limit value greater than the number of values' do
      let(:limit) { 2 }
      let(:values) { %w[a] }

      it 'returns false' do
        expect(component.truncate_values_list?).to be false
      end
    end

    context 'when the field configuration does not include a limit' do
      let(:limit) { nil }
      let(:values) { %w[a] }

      it 'returns false' do
        expect(component.truncate_values_list?).to be false
      end
    end
  end

  describe '#limited_field_values' do
    context 'when the field configuration includes a limit' do
      let(:limit) { 1 }
      let(:values) { %w[a b] }

      it 'truncates a long list of values' do
        expect(component.limited_field_values).to eq %w[a]
      end
    end

    context 'when the field configuration does not include a limit' do
      let(:limit) { nil }
      let(:values) { %w[a b] }

      it 'does not truncate a long list of values' do
        expect(component.limited_field_values).to eq values
      end
    end
  end
end
