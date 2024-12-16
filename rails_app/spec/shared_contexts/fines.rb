# frozen_string_literal: true

# stub alma fine set
shared_context 'with mock alma fine_set' do
  before do
    fine_set = instance_double(Alma::FineSet)
    fine = Alma::AlmaRecord.new(penalty_data)
    allow(alma_user).to receive(:fines).and_return(fine_set)
    allow(fine_set).to receive(:each).and_yield(fine)
  end
end
