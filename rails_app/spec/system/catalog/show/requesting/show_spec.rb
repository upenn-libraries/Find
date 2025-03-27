# frozen_string_literal: true

require 'system_helper'

describe 'Catalog show page requesting behaviors' do
  include_context 'with print monograph record with 2 physical entries'
  include_context 'with empty hathi response'

  let(:user) { create(:user) }
  let(:mms_id) { print_monograph_bib }

  context 'when logged in' do
    include_context 'with mocked illiad_record on user'

    let(:entries) { print_monograph_entries }

    before do
      sign_in user
      visit solr_document_path(mms_id)
      click_button entries.second.description
    end

    it 'shows the button to request the item' do
      within('details.fulfillment') do
        expect(page).to have_selector 'summary', text: I18n.t('requests.form.request_item')
      end
    end

    context 'when holding is a boundwith' do
      let(:item) { build :item, :boundwith }

      before do
        allow(Inventory::Item).to receive(:find_all).and_return([item])
        allow(item).to receive(:alma_pickup?).and_return(true)
        find('details.fulfillment > summary').click
      end

      it 'shows boundwith notice' do
        expect(page).to have_text I18n.t('requests.form.options.boundwith')
      end
    end

    context 'when an item is available but Alma prohibits pickup requests' do
      let(:item) { build :item, :in_place_with_restricted_short_loan_policy }

      before do
        allow(Inventory::Item).to receive(:find_all).and_return([item])
        allow(Inventory::Item).to receive(:find).and_return(item)
        find('details.fulfillment > summary').click
      end

      it 'shows on-site use messaging' do
        expect(page).to have_text I18n.t('requests.form.options.onsite.info', library: item.location.library_name)
      end
    end

    context 'with a holding that has multiple checkoutable items' do
      let(:items) { build_list :item, 2 }

      before do
        allow(Inventory::Item).to receive(:find_all).and_return(items)
        allow(Inventory::Item).to receive(:find).and_return(items.first)
        find('details.fulfillment > summary').click
      end

      it 'shows the item dropdown when there are more than one item' do
        expect(page).to have_selector 'select#item_id'
      end

      it 'shows request options when an item is selected' do
        find('select#item_id').find(:option, items.first.description).select_option
        expect(page).to have_selector '#delivery-options'
      end

      it 'shows preselected option as scan & deliver' do
        find('select#item_id').find(:option, items.first.description).select_option
        within '.request-buttons' do
          expect(page).to have_link I18n.t('requests.form.buttons.scan')
        end
      end
    end

    context 'when adding comments to a request' do
      let(:item) { build :item }

      before do
        allow(Inventory::Item).to receive(:find_all).and_return([item])
        find('details.fulfillment > summary').click
        find('input#delivery_pickup').click
      end

      it 'shows a button to add comments when the option is changed from scan' do
        within('#add-comments') do
          expect(page).to have_link I18n.t('requests.form.add_comments')
        end
      end

      it 'hides the comments area when the option is changed back to scan' do
        find('input#delivery_electronic').click
        within('form.fulfillment-form') do
          expect(page).not_to have_selector '#add-comments'
        end
      end

      it 'expands the comments area when the button is clicked' do
        click_link I18n.t('requests.form.add_comments')
        within('#add-comments') do
          expect(page).to have_selector 'textarea#comments'
        end
      end
    end

    context 'with an item that is unavailable' do
      let(:item) { build :item, :not_in_place }

      before do
        allow(Inventory::Item).to receive(:find_all).and_return([item])
        find('details.fulfillment > summary').click
      end

      it 'shows a note about about ILL fulfillment' do
        within('.fulfillment__container') do
          expect(page).to have_content I18n.t('requests.form.only_ill_requestable')
        end
      end

      it 'shows preselected option as scan & deliver' do
        within '.request-buttons' do
          expect(page).to have_link I18n.t('requests.form.buttons.scan')
        end
      end

      context 'when user a courtesy borrower' do
        let(:user) { create(:user, :courtesy_borrower) }

        it 'shows message saying the item is unavailable without an ILL request link' do
          expect(page).to have_content I18n.t('requests.form.options.none.info')
        end

        it 'does not show any pickup options' do
          within('.fulfillment__container') do
            expect(page).not_to have_selector 'input'
            expect(page).to have_text I18n.t('requests.form.options.none.info')
          end
        end
      end
    end

    context 'with an item that is unavailable and not able to be handled by ILL' do
      let(:item) { build :item, :laptop_material_type_not_in_place }

      before do
        allow(Inventory::Item).to receive(:find_all).and_return([item])
        find('details.fulfillment > summary').click
      end

      it 'does not show any pickup options' do
        within('.fulfillment__container') do
          expect(page).not_to have_selector 'input'
          expect(page).to have_text I18n.t('requests.form.options.none.info')
        end
      end
    end
  end

  context 'when not logged in' do
    before do
      visit solr_document_path(mms_id)
      click_button print_monograph_entries.first.description
    end

    context 'with an aeon requestable item' do
      let(:print_monograph_entries) do
        [create(:physical_entry, mms_id: print_monograph_bib, holding_id: '1234', location_code: 'scrare')]
      end
      let(:item) { build :item, :aeon_location }

      before do
        allow(Inventory::Item).to receive(:find_all).and_return([item])
        find('details.fulfillment > summary').click
      end

      it 'shows the aeon request options' do
        within('.fulfillment__container') do
          expect(page).to have_selector '#aeon-option'
        end
      end

      it 'shows the schedule visit button with aeon href' do
        within('.request-buttons') do
          aeon_link = find_link I18n.t('requests.form.buttons.aeon')
          expect(aeon_link[:href]).to start_with(Settings.aeon.requesting_url)
          expect(aeon_link[:href]).to include(CGI.escape(item.bib_data['title']))
        end
      end
    end

    context 'with an item at the archives' do
      let(:print_monograph_entries) do
        [create(:physical_entry, mms_id: print_monograph_bib, holding_id: '1234',
                                 library_code: Settings.fulfillment.restricted_libraries.archives)]
      end
      let(:item) { build :item, :at_archives }

      before do
        allow(Inventory::Item).to receive(:find_all).and_return([item])
        find('details.fulfillment > summary').click
      end

      it 'shows the archives text' do
        within('.fulfillment__container') do
          expect(page).to have_selector '#archives-option'
        end
      end
    end

    context 'with an item at HSP' do
      let(:print_monograph_entries) do
        [create(:physical_entry, mms_id: print_monograph_bib, holding_id: '1234',
                                 library_code: Settings.fulfillment.restricted_libraries.hsp)]
      end
      let(:item) { build :item, :at_hsp }

      before do
        allow(Inventory::Item).to receive(:find_all).and_return([item])
        find('details.fulfillment > summary').click
      end

      it 'shows the archives text' do
        within('.fulfillment__container') do
          expect(page).to have_selector '#hsp-option'
        end
      end
    end
  end
end
