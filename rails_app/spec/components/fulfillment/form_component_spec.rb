# frozen_string_literal: true

describe Fulfillment::FormComponent, type: :components do
  include_context 'with mocked illiad_record on user'

  let(:user) { create :user }

  before do
    render_inline(
      described_class.new(user: user, mms_id: items.first.id, holding_id: items.first.holding_id, items: items)
    )
  end

  context 'with a bound-with item' do
    let(:items) { [build(:item, :boundwith)] }

    it 'shows boundwith notice' do
      expect(page).to have_text I18n.t('requests.form.options.boundwith')
    end
  end

  context 'with a single item' do
    let(:items) { [build(:item)] }

    it 'renders the available fulfillment options' do
      expect(page).to have_text I18n.t('requests.form.heading')
    end
  end

  context 'with a single item only usable on-site' do
    let(:items) { [build(:item, :in_place_with_restricted_short_loan_policy)] }

    it 'shows on-site use messaging' do
      expect(page).to have_text I18n.t('requests.form.options.onsite.info', library: items.first.location.library_name)
    end
  end

  context 'with an unavailable item' do
    let(:items) { [build(:item, :not_in_place)] }

    it 'shows a note about about ILL fulfillment' do
      expect(page).to have_content I18n.t('requests.form.only_ill_requestable')
    end
  end

  context 'with multiple items that are able to be checked out' do
    let(:items) { build_list :item, 2 }

    it 'renders the item picker' do
      expect(page).to have_selector 'select#item_id'
    end
  end
end
