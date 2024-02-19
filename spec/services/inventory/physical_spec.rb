# frozen_string_literal: true

describe Inventory::Physical do
  let(:mms_id) { '9979338417503681' }
  let(:inventory) do
    described_class.new(mms_id, { 'holding_id' => '22810131440003681',
                                  'institution' => '01UPENN_INST',
                                  'library_code' => 'VanPeltLib',
                                  'location' => 'Stacks',
                                  'call_number' => 'HQ801 .D43 1997',
                                  'availability' => 'available',
                                  'total_items' => '1',
                                  'non_available_items' => '0',
                                  'location_code' => 'vanp',
                                  'call_number_type' => '0',
                                  'priority' => '1',
                                  'library' => 'Van Pelt Library',
                                  'inventory_type' => 'physical' }, [])
  end

  describe '#href' do
    it 'returns the expected path' do
      expect(inventory.href).to eq Rails.application.routes.url_helpers.solr_document_path(mms_id, anchor: inventory.id)
    end
  end
end
