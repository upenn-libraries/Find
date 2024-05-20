# frozen_string_literal: true

describe Inventory::Entry::AvailableStatus do
  subject(:availability_status)  { described_class.new(**location_opts) }

  context 'with an offsite location' do
    let(:location_opts) { { library_code: Inventory::Constants::LIBRA_LIBRARY, location_code: 'stor' } }

    it { expect(availability_status.refined).to eq :offsite }
    it { expect(availability_status.label).to eq I18n.t('alma.availability.available.physical.offsite.label') }
    it { expect(availability_status.description).to eq I18n.t('alma.availability.available.physical.offsite.description') }
  end

  context 'with an Aeon location' do
    let(:location_opts) { { library_code: 'KatzLib', location_code: 'cjsambx' } }

    it { expect(availability_status.refined).to eq :appointment }
    it { expect(availability_status.label).to eq I18n.t('alma.availability.available.physical.appointment.label') }
    it { expect(availability_status.description).to eq I18n.t('alma.availability.available.physical.appointment.description') }
  end

  context 'with an offsite Aeon location' do
    let(:location_opts) { { library_code: Inventory::Constants::LIBRA_LIBRARY, location_code: 'athstor' } }

    it { expect(availability_status.refined).to eq :appointment }
    it { expect(availability_status.label).to eq I18n.t('alma.availability.available.physical.appointment.label') }
    it { expect(availability_status.description).to eq I18n.t('alma.availability.available.physical.appointment.description') }
  end

  context 'with an unrequestable location' do
    let(:location_opts) { { library_code: Inventory::Constants::HSP_LIBRARY, location_code: 'hspclosed' } }

    it { expect(availability_status.refined).to eq :unrequestable }
    it { expect(availability_status.label).to eq I18n.t('alma.availability.available.physical.unrequestable.label') }
    it { expect(availability_status.description).to eq I18n.t('alma.availability.available.physical.unrequestable.description') }
  end

  context 'with a circulating location' do
    let(:location_opts) { { library_code: 'vanpelt', location_code: 'vanp' } }

    it { expect(availability_status.refined).to eq :circulates }
    it { expect(availability_status.label).to eq I18n.t('alma.availability.available.physical.circulates.label') }
    it { expect(availability_status.description).to eq I18n.t('alma.availability.available.physical.circulates.description') }
  end
end
