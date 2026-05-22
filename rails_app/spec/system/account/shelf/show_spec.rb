# frozen_string_literal: true

require 'system_helper'

describe 'Account Shelf show page' do
  let(:user) { create(:user) }
  let(:shelf) { instance_double(Shelf::Service) }

  before do
    login_as user
    # Stub creation of shelf instance, transaction find
    allow(Shelf::Service).to receive(:new).with(user.uid).and_return(shelf)
    allow(shelf).to receive(:find).with(entry.system.to_s, entry.type.to_s, entry.id.to_s).and_return(entry)
    visit request_path(entry.system, entry.type, entry.id)
  end

  context 'when displaying ill transaction' do
    let(:entry) { create(:ill_transaction) }

    it 'displays all expected information' do
      expect(page).to have_text "#{entry.title} #{entry.author}"
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
      expect(page).to have_text "#{entry.title} #{entry.author}"
      expect(page).to have_text entry.status
    end

    context 'when not a resource sharing hold' do
      let(:shelf_listing) { create(:shelf_listing) }

      before do
        # Stub cancellation of hold, find all requests
        allow(shelf).to receive_messages(cancel_hold: nil, find_all: shelf_listing)
      end

      it 'displays cancel button' do
        expect(page).to have_button I18n.t('account.shelf.cancel.button')
      end

      it 'displays record link' do
        expect(page).to have_link I18n.t('account.shelf.bib_record_link')
      end

      it 'redirects to shelf index after canceling hold' do
        click_button I18n.t('account.shelf.cancel.button')
        within('.alert') do
          expect(page).to have_text I18n.t('account.shelf.cancel.success')
        end
        expect(page).to have_current_path(requests_path)
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

    context 'when a boundwith hold' do
      let(:entry) { create(:ils_hold, :boundwith) }

      it 'display boundwith notice' do
        expect(page).to have_text I18n.t('account.shelf.boundwith_notice')
      end

      it 'does not display record link' do
        expect(page).not_to have_link I18n.t('account.shelf.bib_record_link')
      end
    end
  end

  context 'when displaying ils loan' do
    let(:entry) { create(:ils_loan) }

    it 'displays all expected information' do
      expect(page).to have_text "#{entry.title} #{entry.author}"
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

    context 'when a boundwith loan' do
      let(:entry) { create(:ils_loan, :boundwith) }

      it 'display boundwith notice' do
        expect(page).to have_text I18n.t('account.shelf.boundwith_notice')
      end

      it 'does not display record link' do
        expect(page).not_to have_link I18n.t('account.shelf.bib_record_link')
      end
    end
  end
end
