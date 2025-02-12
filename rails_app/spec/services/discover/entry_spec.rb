# frozen_string_literal: true

describe Discover::Entry do
  let(:args) { {} }
  let(:entry) { described_class.new(**args) }

  describe '#initialize' do
    let(:args) do
      { title: 'title', body: { author: 'author', format: 'book', location: 'library' },
        identifiers: { isbn: '123456789' }, link_url: 'https://record.edu', thumbnail_url: 'https://thumbnail.edu' }
    end

    it 'creates the expected instance variables' do
      expect(entry.instance_variables).to contain_exactly(:@title, :@body, :@identifiers, :@link_url, :@thumbnail_url)
    end

    it 'sets the expected title value' do
      expect(entry.title).to eq(args[:title])
    end

    it 'sets the expected body value' do
      expect(entry.body).to eq(args[:body])
    end

    it 'sets the expected identifiers value' do
      expect(entry.identifiers).to eq(args[:identifiers])
    end

    it 'sets the expected link_url value' do
      expect(entry.link_url).to eq(args[:link_url])
    end

    it 'sets the expected thumbnail_url value' do
      expect(entry.thumbnail_url).to eq(args[:thumbnail_url])
    end
  end
end
