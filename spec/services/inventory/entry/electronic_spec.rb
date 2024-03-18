# frozen_string_literal: true

describe Inventory::Entry::Electronic do
  let(:entry) do
    create(
      :electronic_entry, mms_id: '9977047322103681', portfolio_pid: '53496697910003681',
      collection_id: '61496697940003681', activation_status: 'Available', library_code: 'VanPeltLib',
      collection: 'Nature Publishing Journals', coverage_statement: 'Available from 1869 volume: 1 issue: 1.',
      interface_name: 'Nature', inventory_type: 'electronic'
    )
  end

  describe '#status' do
    it 'returns expected status' do
      expect(entry.status).to eq 'Available'
    end
  end

  describe '#id' do
    it 'returns expected id' do
      expect(entry.id).to eq '53496697910003681'
    end
  end

  describe '#description' do
    it 'returns expected description' do
      expect(entry.description).to eql 'Nature Publishing Journals'
    end
  end

  describe '#coverage_statement' do
    it 'returns expected coverage_statement' do
      expect(entry.coverage_statement).to eql 'Available from 1869 volume: 1 issue: 1.'
    end
  end

  describe '#href' do
    it 'returns the expected URI' do
      expect(entry.href).to eq(
        "https://#{described_class::HOST}#{described_class::PATH}?Force_direct=true&portfolio_pid=" \
        "#{entry.id}&rfr_id=info%3Asid%2Fprimo.exlibrisgroup.com&u.ignore_date_coverage=true"
      )
    end
  end

  describe '#format' do
    it 'returns the expected format'
  end

  describe '#electronic?' do
    it 'returns true' do
      expect(entry.electronic?).to be true
    end
  end

  describe '#physical?' do
    it 'returns false' do
      expect(entry.physical?).to be false
    end
  end

  describe '#resource_link?' do
    it 'returns false' do
      expect(entry.resource_link?).to be false
    end
  end
end
