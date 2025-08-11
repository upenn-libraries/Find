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
    let(:alma_user_group) { Settings.fulfillment.docdel_user_groups.sample }
    let(:user) { request.requester }
    let(:message_double) { instance_double ActionMailer::MessageDelivery, deliver_now: true }

    include_context 'with mock alma_record on user having alma_user_group user group'

    before do
      allow(DocdelMailer).to receive(:docdel_email).with(request: request)
                                                   .and_return(message_double)
    end

    context 'with a successful item-level request' do
      let(:request) { build(:fulfillment_request, :with_item, :docdel) }

      it 'returns a successful outcome and sends an email' do
        result = described_class.submit(request: request)
        expect(result.success?).to be true
        expect(message_double).to have_received(:deliver_now)
      end
    end

    context 'with a successful request form submission' do
      let(:request) { build(:fulfillment_request, :docdel, :with_section) }

      it 'returns successful outcome' do
        outcome = described_class.submit(request: request)
        expect(outcome).to be_success
        allow(DocdelMailer).to receive(:docdel_email).with(request: request)
                                                     .and_return(message_double)
      end
    end
  end
end
