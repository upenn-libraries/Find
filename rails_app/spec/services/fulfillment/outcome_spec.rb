# frozen_string_literal: true

describe Fulfillment::Outcome do
  let(:outcome) { described_class.new(**params) }
  let(:request) { build(:fulfillment_request, :with_item, :pickup) }

  context 'with errors present' do
    let(:params) { { errors: ['Error message'], request: request } }

    it 'has errors' do
      expect(outcome.errors).to eq params[:errors]
    end

    it 'has a failed state' do
      expect(outcome).to be_failed
    end
  end

  context 'with no errors' do
    let(:params) { { request: request, confirmation_number: '54321' } }

    it 'has a success state' do
      expect(outcome).to be_success
    end

    it 'has a confirmation number' do
      expect(outcome.confirmation_number).to eq params[:confirmation_number]
    end

    it 'has the proper item_desc' do
      expect(outcome.item_desc).to eq("#{request.params.title} - #{request.params.author}")
    end

    it 'has the proper fulfillment_desc' do
      pickup_location = outcome.send(:human_readable_pickup_location)
      expect(pickup_location).to be_present
      expect(outcome.fulfillment_desc).to eq(
        I18n.t('fulfillment.outcome.email.pickup', pickup_location: outcome.send(:human_readable_pickup_location))
      )
    end
  end

  context 'with an ILL_PICKUP request' do
    let(:params) do
      { request: build(:fulfillment_request, :with_item, :ill_pickup, pickup_location: 'Van Pelt Library'),
        confirmation_number: '87654' }
    end

    it 'has the proper fulfillment_desc' do
      pickup_location = outcome.send(:human_readable_pickup_location)
      expect(pickup_location).to be_present
      expect(outcome.fulfillment_desc).to eq(
        I18n.t('fulfillment.outcome.email.pickup', pickup_location: pickup_location)
      )
    end
  end
end
