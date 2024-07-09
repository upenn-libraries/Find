# frozen_string_literal: true

describe Inventory::Electronic::Notes do
  let(:data) { { 'public_note' => 'pub note', 'authentication_note' => 'auth note' } }
  let(:notes) { described_class.new(data) }

  describe '#initialize' do
    context 'when data argument is empty' do
      let(:data) { {} }

      it 'creates data hash with note fields' do
        expect(notes.data.map { |k, _v| k }).to eq(described_class::FIELDS)
      end
    end
  end

  describe '#fetch' do
    let(:data) { { 'public_note' => 'pub note', 'authentication_note' => 'auth note', 'not-a-note' => 'nope' } }

    it 'returns only note fields' do
      expect(notes.fetch(data)).to eq data.except('not-a-note')
    end
  end

  describe '#missing?' do
    context 'with all notes present' do
      it 'return false' do
        expect(notes.missing?).to eq false
      end
    end

    context 'with some notes blank' do
      let(:data) { { 'public_note' => 'pub note', 'authentication_note' => '' } }

      it 'return true' do
        expect(notes.missing?).to eq true
      end
    end
  end

  describe '#update' do
    let(:new_data) { { 'public_note' => 'updated', 'authentication_note' => 'note', 'not-a-note' => 'nope' } }

    context 'when there are no notes missing' do
      it 'retains the initial values' do
        expect(notes.update(new_data)).to eq data
      end

      it 'does not alter stored note data' do
        stored_data = notes.data
        notes.update(new_data)
        expect(notes.data).to eq stored_data
      end
    end

    context 'when there are notes missing' do
      let(:data) { { 'public_note' => '', 'authentication_note' => 'auth note', 'not-a-note' => 'nope' } }

      it 'updates the missing values' do
        expect(notes.update(new_data)).to eq({ 'public_note' => 'updated', 'authentication_note' => 'auth note' })
      end

      it 'alters stored note data' do
        notes.update(new_data)
        expect(notes.data).to eq({ 'public_note' => 'updated', 'authentication_note' => 'auth note' })
      end
    end

    context 'when new data has no notes' do
      let(:new_data) { { 'public_note' => '', 'authentication_note' => '' } }

      it 'returns nil' do
        expect(notes.update(new_data)).to be_nil
      end

      it 'does not alter stored note data' do
        notes.update(new_data)
        expect(notes.data).to eq data.except('not-a-note')
      end
    end
  end

  describe '#all' do
    it 'returns all present notes' do
      expect(notes.all).to contain_exactly(data['public_note'], data['authentication_note'])
    end

    context 'with blank notes' do
      let(:data) { { 'public_note' => '', 'authentication_note' => '' } }

      it 'removes them' do
        expect(notes.all).to eq []
      end
    end
  end
end
