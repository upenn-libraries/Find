# frozen_string_literal: true

require 'system_helper'

describe 'Account Request ILL form' do
  let(:user) { create(:user) }
  let(:open_params) { {} }

  before do
    sign_in user

    visit ill_new_request_path(**open_params)
  end

  context 'when request has open params' do
    let(:open_params) { { 'requesttype' => 'book', 'booktitle' => 'Gone with the Wind', 'au' => 'Margaret Mitchell' } }

    it 'opens appropriate form' do
      expect(page).to have_button 'Book or other item', class: 'active'
      expect(page).to have_button 'Article or chapter', class: '!active'
    end

    it 'populates title field' do
      expect(page).to have_field 'title', with: 'Gone with the Wind'
    end

    it 'populates author field' do
      expect(page).to have_field 'author', with: 'Margaret Mitchell'
    end
  end

  context 'when request does not have open params' do
    it 'does not open either form' do
      expect(page).to have_button 'Book or other item', class: '!active'
      expect(page).to have_button 'Article or chapter', class: '!active'
    end
  end

  context 'when request has a requestype that is not book or article' do
    let(:open_params) { { 'requesttype' => 'invalid', 'title' => 'Gone with the Wind' } }

    it 'opens article form (the default)' do
      expect(page).to have_button 'Book or other item', class: '!active'
      expect(page).to have_button 'Article or chapter', class: 'active'
    end
  end
end
