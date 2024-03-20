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

  it 'does not display the staff view tool' do
    within('div.bookmarksTools') do
      expect(page).not_to have_text('Staff View')
    end
  end
end
