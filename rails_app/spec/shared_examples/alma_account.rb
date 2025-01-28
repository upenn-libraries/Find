# frozen_string_literal: true

shared_examples_for 'Alma Account' do
  include Alma::ApiMocks::User

  before do
    stub_alma_user_find_success(id: alma_record[:primary_id],
                                response_body: build(:alma_user_response, primary_id: alma_record[:primary_id]))
  end

  describe '#work_order_operator?' do
    context 'when the role is present and active' do
      let(:alma_record) { create(:alma_user_response, :work_order_operator_active) }

      it 'returns true' do
        expect(object.work_order_operator?).to be false
      end
    end

    context 'when the role is present but inactive' do
      let(:alma_record) { create(:alma_user_response, :work_order_operator_inactive) }

      it 'returns false' do
        expect(object.work_order_operator?).to be false
      end
    end

    context 'when the role is not present' do
      let(:alma_record) { create(:alma_user_response) }

      it 'returns false' do
        expect(object.work_order_operator?).to be false
      end
    end
  end
end
