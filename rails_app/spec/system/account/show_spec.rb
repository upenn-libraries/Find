# frozen_string_literal: true

require 'system_helper'

describe 'Account Show Page' do
  let(:user) { create(:user) }

  before do
    sign_in user
    visit account_path
  end

  it 'links to shelf' do
    within('.cards-as-links') do
      expect(page).to have_link(I18n.t('account.show.cards.shelf.title'), href: shelf_path)
    end
  end

  it 'links to settings' do
    within('.cards-as-links') do
      expect(page).to have_link(I18n.t('account.show.cards.settings.title'), href: settings_path)
    end
  end

  it 'links to bookmarks' do
    within('.cards-as-links') do
      expect(page).to have_link(I18n.t('account.show.cards.bookmarks.title'), href: bookmarks_path)
    end
  end

  it 'links to account fines and fees' do
    within('.cards-as-links') do
      expect(page).to have_link(I18n.t('account.show.cards.fines_and_fees.title'), href: fines_and_fees_path)
    end
  end
end
