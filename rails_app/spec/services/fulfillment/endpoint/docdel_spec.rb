# frozen_string_literal: true

describe Fulfillment::Endpoint::Docdel do
  describe '.validate' do
    subject(:errors) { described_class.validate(request: bad_request) }

    context 'when mms_id is missing' do
      let(:bad_request) { build(:fulfillment_request, :with_item, :docdel, mms_id: nil) }

      it 'returns expected error message' do
        expect(errors).to contain_exactly I18n.t('fulfillment.validation.no_mms_id')
      end
    end

    context 'when holding_id is missing' do
      let(:bad_request) { build(:fulfillment_request, :with_item, :docdel, holding_id: nil) }

      it 'returns expected error message' do
        expect(errors).to contain_exactly I18n.t('fulfillment.validation.no_holding_id')
      end
    end

    context 'when missing patron' do
      let(:bad_request) { build(:fulfillment_request, :with_item, :docdel, requester: nil) }

      it 'returns expected error message' do
        expect(errors).to contain_exactly I18n.t('fulfillment.validation.no_user_id')
      end
    end

    context 'when request is proxied' do
      let(:bad_request) { build(:fulfillment_request, :with_item, :docdel, :proxied) }

      it 'returns expected error message' do
        expect(errors).to contain_exactly I18n.t('fulfillment.validation.no_proxy_requests')
      end
    end
  end

  describe '.submit' do
    # TODO: stub Alma user lookup

    context 'with a successful item-level request' do
      let(:item_level_request) { build(:fulfillment_request, :with_item, :docdel) }

      # TODO: stub mailer?

      it 'returns a successful outcome' do
        outcome = described_class.submit(request: item_level_request)
        expect(outcome).to be_success
        # expect(DocdelMailer)
      end
    end

    context 'with a successful request form submission' do
      let(:request_form_request) { build(:fulfillment_request, :docdel, :with_section) }

      it 'returns successful outcome' do
        outcome = described_class.submit(request: request_form_request)
        expect(outcome).to be_success
        # expect(DocdelMailer)
      end
    end
  end
end
