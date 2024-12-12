# frozen_string_literal: true

# stub alma fine set
shared_context 'with mock alma fine_set' do
  before do
    fine_set = instance_double(Alma::FineSet)
    # this context can be used for both fees and fines
    fee_or_fine = %i[single_fine single_fee].find { |f| respond_to?(f) }
    allow(alma_user).to receive(:fines).and_return(fine_set)
    record = Alma::AlmaRecord.new(send(fee_or_fine))
    allow(fine_set).to receive(:each).and_yield(record)
  end
end
