# frozen_string_literal: true

describe Suggester::Engines::Registry do
  include_context 'with cleared engine registry'
  include Suggester::SpecHelpers
  describe '.register' do
    context 'when class inherits from SuggestionEngine' do
      it 'adds subclass to the registry' do
        klass = mock_engine_class
        described_class.register(klass)
        expect(described_class.registry).to include(klass)
      end
    end

    context 'when class does not inherit from SuggestionEngine' do
      it 'raises an error' do
        klass = Object
        message = "#{klass} must inherit from #{described_class::BASE_CLASS}"
        expect { described_class.register(klass) }.to raise_error(described_class::Error, message)
      end
    end
  end

  describe '.available_engines' do
    let(:engine_class) { mock_engine_class }
    let(:engines) { [engine_class, engine_class] }
    let(:context) { {} }
    let(:query) { 'test' }

    it 'instantiates the engines' do
      instances = described_class.available_engines(query: query, context: context, engines: engines)
      expect(instances.all? { |instance| instance.instance_of? engine_class }).to be true
    end
  end
end
