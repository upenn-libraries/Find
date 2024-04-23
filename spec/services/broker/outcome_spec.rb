# frozen_string_literal: true

describe Broker::Outcome do
  let(:outcome) { described_class.new(**params) }
  let(:request) { build(:broker_request, :with_item, :pickup) }

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

    xit 'has a description' do
      expect(outcome.description).to eq request.description
    end
  end
end
