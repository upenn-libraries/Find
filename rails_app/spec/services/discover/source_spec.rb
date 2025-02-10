# frozen_string_literal: true

describe Discover::Source do
  let(:source) { described_class }

  describe '.klass' do
    context 'with an invalid source' do
      it 'raises an error' do
        expect { described_class.klass(source: 'invalid') }
          .to raise_error(Discover::Source::Error, /source invalid has not been configured/)
      end
    end

    context 'with a blacklight source' do
      it 'returns the blacklight source class' do
        expect(described_class.klass(source: 'find')).to eq(Discover::Source::Blacklight)
      end
    end

    context 'with a pse source' do
      it 'returns the pse source class' do
        expect(described_class.klass(source: 'museum')).to eq(Discover::Source::PSE)
      end
    end
  end

  describe '.create_source' do
    context 'with an invalid source' do
      it 'raises an error' do
        expect { described_class.create_source(source: 'invalid') }
          .to raise_error(Discover::Source::Error, /source invalid has not been configured/)
      end
    end

    context 'with a blacklight source' do
      it 'returns a blacklight source object' do
        expect(described_class.create_source(source: 'find')).to be_a(Discover::Source::Blacklight)
      end
    end

    context 'with a pse source' do
      it 'returns a pse source object' do
        expect(described_class.create_source(source: 'museum')).to be_a(Discover::Source::PSE)
      end
    end
  end

  describe '#connection' do
    let(:base_url) { 'http://blacklight_source.edu/' }

    it 'returns a faraday connection' do
      expect(described_class.new.connection(base_url: base_url)).to be_a(Faraday::Connection)
    end

    it 'correctly configures the base url' do
      expect(described_class.new.connection(base_url: base_url).url_prefix.to_s).to eq base_url
    end
  end
end
