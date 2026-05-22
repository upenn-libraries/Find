# frozen_string_literal: true

describe Account::SettingsComponent, type: :components do
  let(:user) { create(:user) }
  let(:rendered) { render_inline(described_class.new(user: user)) }

  before do
    allow(user).to receive_messages(
      full_name: 'First Last',
      ils_group_name: 'undergraduate',
      bbm_delivery_address: ['123 private road', 'Philadelphia PA 19104'],
      office_delivery_address: nil
    )
  end

  it 'renders the user group' do
    expect(rendered).to have_text 'undergraduate'
  end

  it 'renders the full name' do
    expect(rendered).to have_text 'First Last'
  end

  it 'renders the user email' do
    expect(rendered).to have_text user.email
  end

  it 'renders the books by mail delivery address' do
    expect(rendered).to have_text '123 private road'
    expect(rendered).to have_text 'Philadelphia PA 19104'
  end

  context 'when user has no books by mail address' do
    before { allow(user).to receive(:bbm_delivery_address).and_return([]) }

    it 'renders the empty address message' do
      expect(rendered).to have_text I18n.t('account.settings.bbm.empty_address')
    end
  end

  context 'when user is a faculty express member' do
    let(:user) { create(:user, :faculty_express) }

    before do
      allow(user).to receive_messages(
        full_name: 'First Last',
        ils_group_name: 'Faculty Express',
        bbm_delivery_address: [],
        office_delivery_address: '123 College Hall'
      )
    end

    it 'renders the faculty express section' do
      expect(rendered).to have_text I18n.t('account.settings.faculty_express.heading')
    end

    it 'renders the office delivery address' do
      expect(rendered).to have_text '123 College Hall'
    end
  end

  context 'when user is not a faculty express member' do
    it 'does not render the faculty express section' do
      expect(rendered).not_to have_text I18n.t('account.settings.faculty_express.heading')
    end
  end
end
