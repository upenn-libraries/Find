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

  context 'with a single Aeon item' do
    let(:items) { [build(:item, :aeon_location)] }

    it 'shows the Aeon schedule visit option' do
      expect(page).to have_selector '#aeon-option'
      expect(page).to have_link I18n.t('requests.form.buttons.aeon'),
                                href: /#{Regexp.escape(CGI.escape(items.first.bib_data['title']))}/
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

  context 'with multiple Aeon items' do
    let(:items) { build_list :item, 2, :aeon_location }
    let(:expected_options) { [I18n.t('requests.form.item_placeholder')] + item_options }
    let(:item_options) do
      items.map { |item| item.select_label.first }
    end

    it 'renders the item picker with a blank option before the item options' do
      expect(page).to have_select 'item_id', options: expected_options
      expect(page).to have_no_selector 'select#item_id option[value]:not([value=""])[selected]'
    end
  end
end
