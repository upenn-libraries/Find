# frozen_string_literal: true

shared_examples_for 'Illiad Account' do
  describe '#bbm_delivery_address' do
    before do
      allow(object).to receive(:illiad_record).and_return(illiad_record)
    end

    context 'when bbm address is not set' do
      let(:illiad_record) { create(:illiad_user) }

      it 'returns empty array' do
        expect(object.bbm_delivery_address).to eql []
      end
    end

    context 'when bbm address is set' do
      let(:illiad_record) { create(:illiad_user, :with_bbm_address) }

      it 'returns expected address' do
        expect(object.bbm_delivery_address).to match_array ['1 Smith St.', 'Philadelphia, PA 12345']
      end
    end
  end

  describe '#office_delivery_address' do
    before do
      allow(object).to receive(:illiad_record).and_return(illiad_record)
    end

    context 'when office address is not set' do
      let(:illiad_record) { create(:illiad_user, :with_bbm_address) }

      it 'returns nil' do
        expect(object.office_delivery_address).to be_nil
      end
    end

    context 'when only has office address' do
      let(:illiad_record) { create(:illiad_user, :with_office_address) }

      it 'returns expected address' do
        expect(object.office_delivery_address).to eql '123 College Hall'
      end
    end

    context 'when has office and bbm address' do
      let(:illiad_record) { create(:illiad_user, :with_office_and_bbm_address) }

      it 'returns expected address' do
        expect(object.office_delivery_address).to eql '123 Williams Hall'
      end
    end
  end
end
