# frozen_string_literal: true

require 'system_helper'

describe 'Staff View Page' do
  include_context 'with print monograph record with 2 physical entries'

  shared_examples 'staff view page basics' do
    it 'renders title' do
      expect(page).to have_content I18n.t('staff_view.title')
    end

    it 'renders expected fields' do
      expect(page).to have_selector '.field',
                                    text: /^#{I18n.t('staff_view.leader', leader: '')}/
      expect(page).to have_selector '.field', text: /^001/
    end
  end

  context 'without a logged in user' do
    before do
      visit staff_view_solr_document_path(print_monograph_bib)
    end

    include_examples 'staff view page basics'

    it 'does not show catalog error report button' do
      expect(page).not_to have_button(I18n.t('cataloging_errors.form.title'))
    end
  end

  context 'with a logged in user' do
    let(:user) { create(:user) }

    before do
      login_as user
      visit staff_view_solr_document_path(print_monograph_bib)
    end

    include_examples 'staff view page basics'

    it 'shows catalog error report button' do
      expect(page).to have_button(I18n.t('cataloging_errors.form.title'))
    end
  end
end
