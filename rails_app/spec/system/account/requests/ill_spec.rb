# frozen_string_literal: true

require 'system_helper'

describe 'Account Request ILL form' do
  let(:user) { create(:user) }
  let(:open_params) { {} }

  before do
    sign_in user

    visit ill_new_request_path(**open_params)
  end

  it 'does not display option to proxy' do
    expect(page).not_to have_text I18n.t('account.ill.form.proxy.prompt')
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

    it 'populates the title field' do
      expect(page).to have_field 'title', with: 'Gone with the Wind'
    end
  end

  context 'when form is submitting with missing required fields' do
    before do
      click_button 'Book or other item' # TODO: use internalizations
      fill_in 'Author', with: 'John Doe'
      click_button 'Place request'
    end

    it 'display error messages' do
      expect(page).to have_content I18n.t('account.ill.form.loan.title.help_text')
      expect(page).to have_content I18n.t('account.ill.form.loan.publication_year.help_text')
    end

    it 'does not display error message for author' do
      expect(page).not_to have_content I18n.t('account.ill.form.loan.author.help_text')
    end
  end

  context 'when request is being made by library staff' do
    let(:user) { create(:user, :library_staff) }

    it 'displays option to proxy request' do
      expect(page).to have_text I18n.t('account.ill.form.proxy.prompt')
    end

    context 'when library staff submits proxy form' do
      include_context 'with mocked alma_record on proxy user'

      let(:proxy) { Fulfillment::User.new('jdoe') }

      before do
        fill_in I18n.t('account.ill.form.proxy.pennkey'), with: proxy.uid
        click_button I18n.t('account.ill.form.proxy.submit')
      end

      it 'displays proxied request alert' do
        expect(page).to have_text 'You are proxying a request for John Doe (Undergraduate)'
      end

      it 'fills in proxied user id' do
        expect(page).to have_field :proxy_for, with: proxy.uid, type: :text
      end

      it 'adds hidden fields with proxied user id' do
        expect(page).to have_field :proxy_for, with: proxy.uid, type: :hidden, count: 2
      end
    end
  end
end
