# frozen_string_literal: true

# Shared example to be able to test features across different types of records.
shared_examples 'core show page features' do
  let(:params) { {} }

  before { visit solr_document_path(mms_id, params: params) }

  it 'shows document' do
    expect(page).to have_selector 'div.document-main-section'
  end

  it 'shows some item metadata' do
    expect(page).to have_selector 'dd.blacklight-format_facet'
  end

  it 'displays all entries in navigation' do
    within('#inventory-pills-tab') do
      expect(page).to have_selector('button.inventory-item', count: entries.count)
      expect(page).to have_selector('button.inventory-item.active', count: 1)
    end
  end

  it 'defaults to the first holding in navigation' do
    within('#inventory-pills-tab') do
      expect(page).to have_selector('button.inventory-item.active', text: entries.first.description)
    end
  end

  it 'defaults to the first holding in tab pane' do
    within('#inventory-pills-tabContent') do
      expect(page).to have_selector('.tab-pane', count: 1)
      expect(page).to have_selector('#inventory-0')
    end
  end

  it 'displays correct information in tab page' do
    within('#inventory-pills-tabContent') do
      expect(page).to have_content entries.first.description
      expect(page).to have_content entries.first.coverage_statement
    end
  end

  it 'updates the url with holding ID' do
    expect(page).to have_current_path(solr_document_path(mms_id, params: { hld_id: entries.first.id }))
  end

  context 'when holding_id is provided in params' do
    let(:params) { { hld_id: entries.second.id } }

    it 'displays all entries in navigation' do
      within('#inventory-pills-tab') do
        expect(page).to have_selector('button.inventory-item', count: entries.count)
        expect(page).to have_selector('button.inventory-item.active', count: 1)
      end
    end

    it 'selects the second holding in the navigation' do
      within('#inventory-pills-tab') do
        expect(page).to have_selector('button.inventory-item.active', text: entries.second.description)
      end
    end

    it 'display the second holding in the tab pane' do
      within('#inventory-pills-tabContent') do
        expect(page).to have_selector('.tab-pane', count: 1)
        expect(page).to have_selector('#inventory-1')
      end
    end

    it 'display data for second holding in tab pane' do
      within('#inventory-pills-tabContent') do
        expect(page).to have_content entries.second.description
        expect(page).to have_content entries.second.coverage_statement
      end
    end
  end

  context 'when clicking on a holding' do
    before do
      click_button entries.second.description
    end

    it 'selects the holding in the navigation' do
      within('#inventory-pills-tab') do
        expect(page).to have_selector('button.inventory-item.active', text: entries.second.description)
      end
    end

    it 'displays the selected holding in tab pane' do
      within('#inventory-pills-tabContent') do
        expect(page).to have_selector('.tab-pane', count: 1)
        expect(page).to have_selector('#inventory-1')
      end
    end

    it 'displays data for second holding in tab pane' do
      within('#inventory-pills-tabContent') do
        expect(page).to have_content entries.second.description
        expect(page).to have_content entries.second.coverage_statement
      end
    end

    it 'updates the url with holding ID' do
      expect(page).to have_current_path(solr_document_path(mms_id, params: { hld_id: entries.second.id }))
    end
  end
end
