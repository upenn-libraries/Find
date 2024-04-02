# frozen_string_literal: true

require 'system_helper'

describe 'Catalog Bookmarks Page' do
  include_context 'with print monograph record with 2 physical entries'

  before do
    visit root_path
    click_on 'Find it'
    check 'Bookmark'
    visit bookmarks_path
  end

  it 'displays some bookmarks' do
    expect(page).to have_selector('article.document-position-1')
  end

  it 'does not display the staff view tool' do
    within('div.bookmarksTools') do
      expect(page).not_to have_text('Staff View')
    end
  end
end
