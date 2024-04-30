# frozen_string_literal: true

require 'system_helper'

describe 'Fines and Fees index page' do
  let(:user) { build(:user) }
  let(:total_fines) { 100.00 }
  let(:single_fine) do
    { 'type' => { 'value' => 'OVERDUEFINE', 'desc' => 'Overdue fine' },
      'balance' => 0.0,
      'original_amount' => 7.0,
      'creation_time' => '2016-11-03T10:59:00Z',
      'title' => 'THIRD WORLD MODERNISM - ARCHITECTURE, DEVELOPMENT AND IDENTITY',
      'transaction' => [{ 'type' => { 'value' => 'WAIVE', 'desc' => 'Waive' },
                          'amount' => 7.0, 'transaction_time' => '2018-09-10T19:41:00.325Z' }] }
  end

  before do
    sign_in user

    # Stub Alma User
    alma_user = instance_double(Alma::User)
    allow(user).to receive(:alma_record).and_return(alma_user)
    allow(alma_user).to receive(:total_fines).and_return(total_fines)

    # Stub Alma::FineSet
    fine_set = instance_double(Alma::FineSet)
    fine = Alma::AlmaRecord.new(single_fine)
    allow(alma_user).to receive(:fines).and_return(fine_set)
    allow(fine_set).to receive(:each).and_yield(fine)

    visit fines_and_fees_path
  end

  it 'shows total fines' do
    expect(page).to have_text "$#{total_fines}"
  end

  it 'shows type of fine' do
    within('.table') do
      expect(page).to have_text(single_fine.dig('type', 'desc'))
    end
  end

  it 'shows the title of the loan' do
    within('.table') do
      expect(page).to have_text(single_fine['title'].titleize.squish)
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
      expect(page).to have_text("$#{single_fine['original_amount']}")
    end
  end

  it 'shows the remaining balance of the fine' do
    within('.table') do
      expect(page).to have_text("$#{single_fine['balance']}")
    end
  end

  context 'when fetching fines raises an error' do
    before do
      sign_in user

      # Stub Alma User
      alma_user = instance_double(Alma::User)
      allow(user).to receive(:alma_record).and_return(alma_user)
      allow(alma_user).to receive(:total_fines).and_return(total_fines)

      # raise error
      allow(alma_user).to receive(:fines).and_raise(StandardError)

      visit fines_and_fees_path
    end

    it 'does not show the fine' do
      within('.table') do
        expect(page).not_to have_text(single_fine.dig('type', 'desc'))
      end
    end

    it 'shows the total balance row' do
      within('.table') do
        expect(page).to have_text I18n.t('account.fines_and_fees.table.th.total')
        expect(page).to have_text "$#{total_fines}"
      end
    end
  end
end
