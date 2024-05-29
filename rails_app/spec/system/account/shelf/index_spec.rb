# frozen_string_literal: true

require 'system_helper'

describe 'Account Shelf index page' do
  let(:user) { build(:user) }
  let(:shelf_listing) { create(:shelf_listing) }

  before do
    sign_in user

    # Stub Shelf Listing
    shelf = instance_double(Shelf::Service)
    allow(Shelf::Service).to receive(:new).with(user.uid).and_return(shelf)
    allow(shelf).to receive(:find_all).and_return(shelf_listing)

    visit requests_path
  end

  it 'displays all entries' do
    shelf_listing.map(&:title).each do |title|
      expect(page).to have_text(title)
    end
  end

  context 'when displaying loans' do
    let(:loan) { shelf_listing.find(&:ils_loan?) }

    it 'shows all expected information' do
      expect(page).to have_text(loan.author)
      expect(page).to have_text(loan.status)
    end

    it 'show renew all button' do
      expect(page).to have_button I18n.t('account.shelf.renew_all.button')
    end
  end

  context 'when display ill transaction' do
    let(:transaction) { shelf_listing.find(&:ill_transaction?) }

    it 'shows all expected information' do
      expect(page).to have_text transaction.author
      expect(page).to have_text transaction.status
    end
  end

  context 'when displaying hold' do
    let(:hold) { shelf_listing.find(&:ils_hold?) }

    it 'shows all expected information' do
      expect(page).to have_text hold.author
      expect(page).to have_text hold.status
    end
  end
end
