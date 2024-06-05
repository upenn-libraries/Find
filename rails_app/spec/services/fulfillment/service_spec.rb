# frozen_string_literal: true

describe Fulfillment::Service do
  let(:result) { described_class.new(request: request).submit }

  describe '#submit' do
    context 'with a submission destined for illiad' do
      let(:backend) { Fulfillment::Endpoint::Illiad }
      let(:request) { build(:fulfillment_request, :with_item, :books_by_mail) }

      context 'with a valid request' do
        let(:validation_errors) { [] }
        let(:outcome) { Fulfillment::Outcome.new(request: request, confirmation_number: 'ILLIAD1234') }

        before do
          allow(backend).to receive(:validate).and_return(validation_errors)
          allow(backend).to receive(:submit).and_return(outcome)
        end

        it 'conveys the outcome from the backend' do
          expect(result).to eq outcome
        end
      end

      context 'with an invalid request' do
        let(:validation_errors) { ['Some required value not set!'] }

        before do
          allow(backend).to receive(:validate).and_return(validation_errors)
        end

        it 'returns a failed outcome' do
          expect(result).to be_a Fulfillment::Outcome
          expect(result.errors).to eq validation_errors
        end
      end
    end

    context 'with a submission destined for Alma' do
      let(:backend) { Fulfillment::Endpoint::Alma }
      let(:request) { build(:fulfillment_request, :with_item, :pickup) }

      context 'with a valid request' do
        let(:validation_errors) { [] }
        let(:outcome) { Fulfillment::Outcome.new(request: request, confirmation_number: 'ALMA1234') }

        before do
          allow(backend).to receive(:validate).and_return(validation_errors)
          allow(backend).to receive(:submit).and_return(outcome)
        end

        it 'conveys the outcome from the backend' do
          expect(result).to eq outcome
        end
      end

      context 'with an invalid request' do
        let(:validation_errors) { ['Some required value not set!'] }
        let(:outcome) { Fulfillment::Outcome.new(request: request, errors: validation_errors) }

        before do
          allow(backend).to receive(:validate).and_return(validation_errors)
        end

        it 'conveys the outcome from the backend' do
          expect(result.errors).to match_array validation_errors
        end
      end
    end
  end
end
