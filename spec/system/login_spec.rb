# frozen_string_literal: true

require 'system_helper'

describe 'login page' do
  before { visit login_path }

  it 'renders the page' do
    expect(page).to have_text('Continue with PennKey')
    click_on ('Continue with PennKey')
    expect(page).to have_text('test')
  end
end
