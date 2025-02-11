# frozen_string_literal: true

require 'system_helper'

describe 'Discover Penn page' do
  before do
    visit discover_path
  end

  # TODO: replace this spec with more substantive ones and meaningful content is added
  it 'includes the site title' do
    expect(page).to have_text I18n.t('discover.site_name')
  end
end
