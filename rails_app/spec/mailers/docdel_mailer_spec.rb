# frozen_string_literal: true

RSpec.describe DocdelMailer do
  describe '#docdel_email' do
    let(:mail) { described_class.docdel_email(request: request) }
    let(:user) { build :user }
    let(:alma_user_data) { { full_name: 'Test User' } }
    let(:item_data) { build(:item_data) }

    include_context 'with mock alma_record on user'
    include_context 'with Availability::Item.find lookup returning item_data'

    context 'with a request submitted for a specific Alma Item' do
      let(:request) do
        build(:fulfillment_request, :with_item, :docdel, :with_comments, :record_page_source, requester: user)
      end

      it 'renders proper headers' do
        expect(mail.to).to eq([Settings.fulfillment.docdel.email])
        expect(mail.reply_to).to eq([request.requester.email])
      end

      it 'includes user information' do
        expect(mail.body.encoded).to include request.requester.full_name
        expect(mail.body.encoded).to include request.requester.email
      end

      it 'includes item information' do
        expect(mail.body.encoded).to include item_data['enumeration_a']
        expect(mail.body.encoded).to include item_data['enumeration_b']
      end

      it 'includes a link to the record page' do
        expect(mail.body.encoded).to include solr_document_path(request.params.mms_id,
                                                                hld_id: request.params.holding_id)
      end

      it 'includes comments' do
        expect(mail.body.encoded).to include request.params.comments
      end
    end

    context 'with a request submitted via the Request form' do
      let(:request) do
        build(:fulfillment_request, :docdel, :with_section, :with_comments, :request_form_source, requester: user)
      end

      it 'includes bibliographic data' do
        expect(mail.body.encoded).to include request.params.title
      end
    end
  end
end
