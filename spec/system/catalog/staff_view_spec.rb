# frozen_string_literal: true

require 'system_helper'

describe 'Catalog Show Page' do
  include_context 'with print monograph record'

  before { visit staff_view_solr_document_path(print_monograph_bib) }

  it 'renders title' do
    expect(page).to have_content I18n.t('staff_view.title')
  end

  it 'renders expected fields' do
    expect(page).to have_selector '.field', text: /^#{I18n.t('staff_view.leader', leader: '')}/
    expect(page).to have_selector '.field', text: /^001/
  end
end
