# frozen_string_literal: true

require 'system_helper'

describe 'Fines and Fees index page' do
  let(:user) { create(:user) }
  let(:total_fines) { 100.00 }
  let(:alma_user) { instance_double(Alma::User) }

  before do
    sign_in user

    # Stub Alma User
    allow(user).to receive(:alma_record).and_return(alma_user)
    allow(alma_user).to receive(:total_fines).and_return(total_fines)
  end

  context 'when fetching fines raises an error' do
    before do
      # raise error
      allow(alma_user).to receive(:fines).and_raise(StandardError)

      visit fines_and_fees_path
    end

    it 'does not show the table' do
      expect(page).not_to have_selector('.table')
      expect(page).not_to have_text(I18n.t('account.fines_and_fees.table.th.last_transaction'))
    end
  end

  context 'with a user having a fine' do
    include_context 'with mock alma fine_set'

    let(:penalty_data) do
      { 'type' => { 'value' => 'OVERDUEFINE', 'desc' => 'Overdue fine' },
        'balance' => 0.0,
        'original_amount' => 7.0,
        'creation_time' => '2016-11-03T10:59:00Z',
        'title' => 'THIRD WORLD MODERNISM - ARCHITECTURE, DEVELOPMENT AND IDENTITY',
        'transaction' => [{ 'type' => { 'value' => 'WAIVE', 'desc' => 'Waive' },
                            'amount' => 7.0, 'transaction_time' => '2018-09-10T19:41:00.325Z' }] }
    end

    before { visit fines_and_fees_path }

    it 'shows total fines' do
      expect(page).to have_text "$#{total_fines}"
    end

    it 'shows type of fine' do
      within('.table') do
        expect(page).to have_text(penalty_data.dig('type', 'desc'))
      end
    end

    it 'shows the title of the loan' do
      within('.table') do
        expect(page).to have_text(penalty_data['title'].titleize.squish)
      end
    end

    it 'shows the date the fine was charged' do
      within('.table') do
        expect(page).to have_text('11/03/2016')
      end
    end

    it 'shows the date of the last transaction' do
      within('.table') do
        expect(page).to have_text('09/10/2018')
      end
    end

    it 'shows the original amount of the fine' do
      within('.table') do
        expect(page).to have_text("$#{penalty_data['original_amount']}")
      end
    end

    it 'shows the remaining balance of the fine' do
      within('.table') do
        expect(page).to have_text("$#{penalty_data['balance']}")
      end
    end
  end

  context 'when a fee has no transaction data' do
    include_context 'with mock alma fine_set'

    let(:penalty_data) do
      { 'type' => { 'value' => 'LOSTITEMREPLACEMENTFEE', 'desc' => 'Lost item replacement fee' },
        'balance' => 125.0,
        'original_amount' => 125.0,
        'creation_time' => '2018-09-10T19:41:00.325Z',
        'title' => 'THIRD WORLD MODERNISM - ARCHITECTURE, DEVELOPMENT AND IDENTITY' }
    end

    before { visit fines_and_fees_path }

    it 'properly renders available information' do
      within('.table') do
        expect(page).to have_text(penalty_data.dig('type', 'desc'))
      end
    end
  end

  context 'when a fine has no title' do
    include_context 'with mock alma fine_set'

    let(:penalty_data) do
      { 'type' => { 'value' => 'CUSTOMER_DEFINED_01', 'desc' => 'WIC Equipment Fine' },
        'balance' => 25.0,
        'remaining_vat_amount' => 0.0,
        'original_amount' => 25.0,
        'creation_time' => '2023-04-07T14:51:52.457Z' }
    end

    before { visit fines_and_fees_path }

    it 'properly renders available information' do
      within('.table') do
        expect(page).to have_text(penalty_data.dig('type', 'desc'))
      end
    end
  end
end
