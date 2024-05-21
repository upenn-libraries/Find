# frozen_string_literal: true

require 'system_helper'

describe 'Account Shelf show page' do
  let(:user) { build(:user) }

  before do
    sign_in user

    # Stub Shelf Listing
    shelf = instance_double(Shelf::Service)
    allow(Shelf::Service).to receive(:new).with(user.uid).and_return(shelf)
    allow(shelf).to receive(:find).with(entry.system.to_s, entry.type.to_s, entry.id.to_s).and_return(entry)

    visit request_path(entry.system, entry.type, entry.id)
  end

  context 'when displaying ill transaction' do
    let(:entry) { create(:ill_transaction) }

    it 'displays all expected information' do
      expect(page).to have_text entry.title
      expect(page).to have_text entry.author
      expect(page).to have_text entry.status
    end

    it 'does not display buttons' do
      expect(page).not_to have_button I18n.t('account.shelf.renew.button')
      expect(page).not_to have_button I18n.t('account.shelf.cancel.button')
    end

    it 'does not display record link' do
      expect(page).not_to have_link I18n.t('account.shelf.bib_record_link')
    end
  end

  context 'when displaying ils hold' do
    let(:entry) { create(:ils_hold) }

    it 'displays all expected information' do
      expect(page).to have_text entry.title
      expect(page).to have_text entry.author
      expect(page).to have_text entry.status
    end

    context 'when not a resource sharing hold' do
      it 'displays cancel button' do
        expect(page).to have_button I18n.t('account.shelf.cancel.button')
      end

      it 'displays record link' do
        expect(page).to have_link I18n.t('account.shelf.bib_record_link')
      end
    end

    context 'when a resource sharing hold' do
      let(:entry) { create(:ils_hold, :resource_sharing) }

      it 'does not display cancel button' do
        expect(page).not_to have_button I18n.t('account.shelf.cancel.button')
      end

      it 'does not display record link' do
        expect(page).not_to have_link I18n.t('account.shelf.bib_record_link')
      end
    end
  end

  context 'when displaying ils loan' do
    let(:entry) { create(:ils_loan) }

    it 'displays all expected information' do
      expect(page).to have_text entry.title
      expect(page).to have_text entry.author
      expect(page).to have_text entry.status
    end

    it 'displays link to record' do
      expect(page).to have_link I18n.t('account.shelf.bib_record_link')
    end

    it 'displays renew button' do
      expect(page).to have_button I18n.t('account.shelf.renew.button')
    end

    context 'when not a renewable loan' do
      let(:entry) { create(:ils_loan, :not_renewable) }

      it 'does not display renew button' do
        expect(page).not_to have_button I18n.t('account.shelf.renew.button')
      end
    end

    context 'when a resource sharing loan' do
      let(:entry) { create(:ils_loan, :resource_sharing) }

      it 'does not display renew button' do
        expect(page).not_to have_button I18n.t('account.shelf.renew.button')
      end

      it 'does not display record link' do
        expect(page).not_to have_link I18n.t('account.shelf.bib_record_link')
      end
    end
  end
end
