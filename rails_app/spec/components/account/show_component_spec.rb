# frozen_string_literal: true

describe Account::ShowComponent, type: :components do
  let(:user) { create(:user) }
  let(:rendered) { render_inline(described_class.new(user: user)) }

  it 'renders a link to shelf' do
    expect(rendered).to have_link(href: shelf_path)
  end

  it 'renders a link to bookmarks' do
    expect(rendered).to have_link(href: bookmarks_path)
  end

  it 'renders a link to fines and fees' do
    expect(rendered).to have_link(href: fines_and_fees_path)
  end

  it 'renders a link to settings' do
    expect(rendered).to have_link(href: settings_path)
  end

  it 'renders a link to the ILL form' do
    expect(rendered).to have_link(href: ill_new_request_path)
  end

  context 'when user is a courtesy borrower' do
    let(:user) { create(:user, :courtesy_borrower) }

    it 'does not render a link to the ILL form' do
      expect(rendered).not_to have_link(href: ill_new_request_path)
    end
  end
end
