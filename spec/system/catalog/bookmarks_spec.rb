# frozen_string_literal: true

require 'system_helper'

describe 'Catalog Bookmarks Page' do
  before do
    allow(Inventory::Service).to receive(:all).and_return(Inventory::Response.new(entries: []))
    SampleIndexer.index 'print_monograph.json'
    visit root_path
    click_on 'Find it'
    check 'Bookmark'
    visit bookmarks_path
  end

  after { SampleIndexer.clear! }

  it 'displays some bookmarks' do
    expect(page).to have_selector('article.document-position-1')
  end

  it 'does not display the staff view tool' do
    within('div.bookmarksTools') do
      expect(page).not_to have_text('Staff View')
    end
  end

  context 'when logged out' do
    let(:user) { create(:user) }

    before do
      allow(User).to receive(:new).and_return(user)
      allow(user).to receive(:exists_in_alma?).and_return(true)
    end

    it 'redirects to bookmarks page after login' do
      visit login_path
      click_on I18n.t('login.pennkey')
      expect(page).to have_current_path(bookmarks_path)
    end
  end
end
