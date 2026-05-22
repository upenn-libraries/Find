# frozen_string_literal: true

describe Account::FinesTableComponent, type: :components do
  let(:user) { create(:user) }
  let(:alma_user) { instance_double(Alma::User) }
  let(:rendered) { render_inline(described_class.new(user: user)) }

  before do
    allow(user).to receive(:alma_record).and_return(alma_user)
    allow(alma_user).to receive(:total_fines).and_return(100.0)
  end

  it 'renders the total fines amount' do
    allow(alma_user).to receive(:fines).and_return(nil)
    expect(rendered).to have_text '$100.00'
  end

  context 'when fines are present' do
    let(:fine_set) { instance_double(Alma::FineSet) }
    let(:fine) do
      Alma::AlmaRecord.new('type' => { 'value' => 'OVERDUEFINE', 'desc' => 'Overdue fine' },
                           'balance' => 0.0, 'original_amount' => 7.0,
                           'creation_time' => '2016-11-03T10:59:00Z')
    end

    before do
      allow(alma_user).to receive(:fines).and_return(fine_set)
      allow(fine_set).to receive(:present?).and_return(true)
      allow(fine_set).to receive(:each).and_yield(fine)
    end

    it 'renders the fines table' do
      expect(rendered).to have_selector('table')
    end
  end

  context 'when fetching fines raises an error' do
    before { allow(alma_user).to receive(:fines).and_raise(StandardError) }

    it 'does not render the fines table' do
      expect(rendered).not_to have_selector('table')
    end
  end
end
