# frozen_string_literal: true

describe Broker::Service do
  let(:outcome) { described_class.new(request: request).submit }

  describe '#submit' do

    before do
      allow(backend).to receive(:validate).and_return(validation_errors)
      allow(backend).to receive(:submit).and_return(outcome)
    end

    context 'with a submission destined for illiad' do
      let(:backend) { Broker::Backend::Illiad }
      let(:request) { build(:broker_request, :with_item, :books_by_mail) }

      context 'with a valid request' do
        let(:validation_errors) { [] }
        let(:outcome) { Broker::Outcome.new(request: request, confirmation_number: 'ILLIAD1234') }

        it 'conveys the outcome from the backend' do
          expect(outcome).to eq outcome
          expect(outcome).to be_success
        end
      end

      context 'with an invalid request' do
        let(:validation_errors) { ['Some required value not set!'] }
        let(:outcome) { Broker::Outcome.new(request: request, errors: 'ILLIAD1234') }

        it 'conveys the outcome from the backend' do
          expect(outcome).to eq outcome
          expect(outcome).to be_failed
        end
      end

    end

    context 'with an ILL loan with books by mail delivery' do; end
    context 'with an ILL loan and campus pickup' do; end
    context 'with an ILL loan and faculty express office delivery' do; end
    context 'with an ILL scan and electronic delivery' do; end
    context 'with an item request and books by mail delivery' do

      before do
        allow(Broker::Backend::Illiad).to receive(:validate).and_return true
        allow(Broker::Backend::Illiad).to receive(:submit).and_return outcome
      end

      it 'does the thing' do
        expect(outcome).to be_a Broker::Outcome
        expect(outcome).to be_success
      end
    end
    context 'with an item request and campus pickup' do; end
    context 'with an item request and aeon fulfillment' do; end
    context 'with an item section request and electronic delivery' do; end
    context 'with a holding request and campus pickup' do; end
  end
end
