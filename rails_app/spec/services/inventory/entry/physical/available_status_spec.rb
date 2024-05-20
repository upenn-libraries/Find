# frozen_string_literal: true

describe Inventory::Entry::Physical::AvailableStatus do
  subject(:availability_status)  { described_class.new(**location_opts) }
  let(:scope) { %i[alma availability available physical] << type }

  shared_examples 'has the correct attribute values' do
    it { expect(availability_status.refined).to eq type }
    it { expect(availability_status.label).to eq I18n.t(:label, scope: scope) }
    it { expect(availability_status.description).to eq I18n.t(:description, scope: scope) }
  end

  context 'with an offsite location' do
    let(:location_opts) { { library_code: Inventory::Constants::LIBRA_LIBRARY, location_code: 'stor' } }
    let(:type) { :offsite }

    include_examples 'has the correct attribute values'
  end

  context 'with an Aeon location' do
    let(:location_opts) { { library_code: 'KatzLib', location_code: 'cjsambx' } }
    let(:type) { :appointment }

    include_examples 'has the correct attribute values'
  end

  context 'with an offsite Aeon location' do
    let(:location_opts) { { library_code: Inventory::Constants::LIBRA_LIBRARY, location_code: 'athstor' } }
    let(:type) { :appointment }

    include_examples 'has the correct attribute values'
  end

  context 'with an unrequestable location' do
    let(:location_opts) { { library_code: Inventory::Constants::HSP_LIBRARY, location_code: 'hspclosed' } }
    let(:type) { :unrequestable }

    include_examples 'has the correct attribute values'
  end

  context 'with a circulating location' do
    let(:location_opts) { { library_code: 'vanpelt', location_code: 'vanp' } }
    let(:type) { :circulates }

    include_examples 'has the correct attribute values'
  end
end
