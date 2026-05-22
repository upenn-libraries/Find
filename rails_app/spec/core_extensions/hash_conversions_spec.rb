# frozen_string_literal: true

describe CoreExtensions::HashConversions do
  describe '#to_openurl' do
    context 'with a OpenURL KEV hash' do
      let(:hash) do
        { 'rft.au' => 'Doe, John',
          'rft.title' => 'Example Title',
          'rft.date' => 2020 }
      end

      it 'returns an OpenURL query string' do
        expect(hash.to_openurl).to eq('rft.au=Doe%2C+John&rft.title=Example+Title&rft.date=2020')
      end
    end

    context 'with an OpenURL KEV hash containing an array' do
      let(:hash) do
        { 'rft.au' => ['Doe, John', 'Smith, Jane'],
          'rft.title' => 'Example Title',
          'rft.date' => 2020 }
      end

      it 'returns an OpenURL query string with duplicate keys' do
        expect(hash.to_openurl).to eq('rft.au=Doe%2C+John&rft.au=Smith%2C+Jane&rft.title=Example+Title&rft.date=2020')
      end
    end

    context 'with an OpenURL KEV hash containing an empty value' do
      let(:hash) do
        { 'rft.au' => 'Doe, John',
          'rft.title' => '',
          'rft.pub' => nil,
          'rft.date' => 2020 }
      end

      it 'returns an OpenURL query string without empty key' do
        expect(hash.to_openurl).to eq('rft.au=Doe%2C+John&rft.date=2020')
      end
    end
  end
end
