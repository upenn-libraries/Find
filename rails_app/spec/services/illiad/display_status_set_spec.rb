# frozen_string_literal: true

describe Illiad::DisplayStatusSet do
  let(:display_statuses) { build_list(:illiad_api_display_status_response, 2) }
  let(:display_status_set) { build(:illiad_display_status_set, display_statuses: display_statuses) }

  describe '.new' do
    it 'creates Illiad:DisplayStatus instances' do
      expect(display_status_set.display_statuses).to all(be_an_instance_of(Illiad::DisplayStatus))
    end
  end

  describe '#display_for' do
    context 'when display status is present' do
      it 'returns display status' do
        expect(display_status_set.display_for('Jim MW Processing')).to eql 'In Process'
      end
    end

    context 'when display status is not present' do
      let(:status) { 'Cancelled by ILL Staff' }

      it 'returns status given' do
        expect(display_status_set.display_for(status)).to eql status
      end
    end
  end
end
