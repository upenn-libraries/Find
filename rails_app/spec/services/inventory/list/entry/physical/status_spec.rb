# frozen_string_literal: true

describe Inventory::List::Entry::Physical::Status do
  shared_examples 'returns expected translation values for' do |value|
    context 'when available' do
      let(:namespace) { %i[alma availability physical available] }

      context 'with an offsite location' do
        subject(:status) { create(:physical_entry_status, :offsite) }

        it 'returns expected translation values' do
          expect(status.send(value)).to eql I18n.t([:offsite, value].join('.'), scope: namespace)
        end
      end

      context 'with an Aeon location' do
        subject(:status) { create(:physical_entry_status, :aeon_onsite) }

        it 'returns expected translation' do
          expect(status.send(value)).to eql I18n.t([:appointment, value].join('.'), scope: namespace)
        end
      end

      context 'with an offsite Aeon location' do
        subject(:status) { create(:physical_entry_status, :aeon_offsite) }

        it 'returns expected translation' do
          expect(status.send(value)).to eql I18n.t([:appointment, value].join('.'), scope: namespace)
        end
      end

      context 'with an unrequestable location' do
        subject(:status) { create(:physical_entry_status, :unrequestable) }

        it 'returns expected translation' do
          expect(status.send(value)).to eql I18n.t([:unrequestable, value].join('.'), scope: namespace)
        end
      end

      context 'with a circulating location' do
        subject(:status) { create(:physical_entry_status) }

        it 'returns expected translation' do
          expect(status.send(value)).to eql I18n.t([:circulates, value].join('.'), scope: namespace)
        end
      end
    end

    context 'when check_holdings' do
      let(:namespace) { %i[alma availability physical check_holdings] }

      context 'with an aeon location' do
        subject(:status) { create(:physical_entry_status, :check_holdings, :aeon_onsite) }

        it 'returns expected translation' do
          expect(status.send(value)).to eql I18n.t([:appointment, value].join('.'), scope: namespace)
        end
      end

      context 'with a non-aeon location' do
        subject(:status) { create(:physical_entry_status, :check_holdings) }

        it 'returns expected translation' do
          expect(status.send(value)).to eql I18n.t([:mixed_availability, value].join('.'), scope: namespace)
        end
      end
    end

    context 'when unavailable' do
      subject(:status) { create(:physical_entry_status, :unavailable) }

      let(:namespace) { %i[alma availability physical unavailable] }

      it 'returns expected translation value' do
        expect(status.send(value)).to eql I18n.t(value, scope: namespace)
      end
    end
  end

  describe '#label' do
    include_examples 'returns expected translation values for', :label

    context 'when a non-standard status' do
      subject(:status) { create(:physical_entry_status, status: 'unknown') }

      it 'returns raw status' do
        expect(status.label).to eql 'Unknown'
      end
    end
  end

  describe '#description' do
    include_examples 'returns expected translation values for', :description

    context 'when a non-standard status' do
      subject(:status) { create(:physical_entry_status, status: 'unknown') }

      it 'returns nil' do
        expect(status.description).to be_nil
      end
    end
  end
end
