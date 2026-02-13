# frozen_string_literal: true

describe Discover::Artifact do
  describe 'validations' do
    it 'is invalid without a title' do
      artifact = build(:artifact, title: nil)

      expect(artifact).not_to be_valid
      expect(artifact.errors[:title]).to include("can't be blank")
    end

    it 'is invalid without a link' do
      artifact = build(:artifact, link: nil)

      expect(artifact).not_to be_valid
      expect(artifact.errors[:link]).to include("can't be blank")
    end
  end

  describe '.search' do
    let!(:statue) { create(:artifact, location: 'America') }
    let!(:brick) do
      create(:artifact,
             title: 'Brick',
             format: 'Clay',
             description: 'This is an amazing clay brick',
             location: 'Near Eastern',
             on_display: true)
    end
    let!(:stela) do
      create(:artifact,
             title: 'Stela',
             format: 'Limestone',
             description: 'CBS Register: piece of blue grey limestone. Stela or Plaque.',
             location: 'Near Eastern',
             on_display: false)
    end

    it 'returns artifact matching full query' do
      expect(described_class.search('statue fragment')).to contain_exactly(statue)
    end

    it 'returns artifact matching partial query' do
      expect(described_class.search('clay')).to contain_exactly(brick)
    end

    it 'returns multiple artifacts when query matches both' do
      expect(described_class.search('near eastern')).to contain_exactly(brick, stela)
    end

    it 'performs case insensitive search' do
      expect(described_class.search('LIMESTONE')).to contain_exactly(stela)
    end

    it 'returns artifacts sorted by relevancy' do
      expect(described_class.search('brick stela')).to eq [brick, stela]
    end

    it 'returns no results for non-matching query' do
      expect(described_class.search('Salvador Dali')).to be_empty
    end

    it 'returns no results for blank query' do
      expect(described_class.search('')).to be_empty
    end

    it 'returns no results for wildcard query' do
      expect(described_class.search('*')).to be_empty
    end
  end
end
