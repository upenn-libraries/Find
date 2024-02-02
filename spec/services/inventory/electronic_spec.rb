# frozen_string_literal: true

describe Inventory::Electronic do
  let(:inventory) do
    described_class.new('9977047322103681', { 'portfolio_pid' => '53496697910003681',
                                              'collection_id' => '61496697940003681',
                                              'activation_status' => 'Available',
                                              'library_code' => 'VanPeltLib',
                                              'collection' => 'Nature Publishing Journals',
                                              'coverage_statement' => 'Available from 1869 volume: 1 issue: 1.',
                                              'interface_name' => 'Nature',
                                              'inventory_type' => 'electronic' }, {})
  end

  describe '#href' do
    it 'returns the expected URI' do
      expect(inventory.href).to eq(
        "https://#{described_class::HOST}#{described_class::PATH}?Force_direct=true&portfolio_pid=" \
        "#{inventory.id}&rfr_id=info%3Asid%2Fprimo.exlibrisgroup.com&u.ignore_date_coverage=true"
      )
    end
  end
end
