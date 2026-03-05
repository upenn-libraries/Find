# frozen_string_literal: true

describe 'Account Controller Requests' do
  let(:user) { create(:user) }

  before do
    login_as user
    get account_path
  end

  it 'links to shelf' do
    expect(response.body).to include shelf_path
    expect(response.body).to include I18n.t('account.show.cards.shelf.title')
  end

  it 'links to ILL form' do
    expect(response.body).to include ill_new_request_path
    expect(response.body).to include I18n.t('account.show.cards.request.title')
  end

  it 'links to settings' do
    expect(response.body).to include settings_path
    expect(response.body).to include I18n.t('account.show.cards.settings.title')
  end

  it 'links to bookmarks' do
    expect(response.body).to include bookmarks_path
    expect(response.body).to include I18n.t('account.show.cards.bookmarks.title')
  end

  it 'links to account fines and fees' do
    expect(response.body).to include fines_and_fees_path
    expect(response.body).to include I18n.t('account.show.cards.fines_and_fees.title')
  end

  context 'when user is courtesy borrower' do
    let(:user) { create(:user, :courtesy_borrower) }

    it 'does not link to ILL form' do
      expect(response.body).not_to include ill_new_request_path
    end
  end
end
