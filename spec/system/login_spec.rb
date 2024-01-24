# frozen_string_literal: true

require 'system_helper'

describe 'login page' do
  before { visit login_path }

  it 'renders the page' do
    expect(page).to have_text('Login')
  end
end
