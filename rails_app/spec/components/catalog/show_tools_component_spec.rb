# frozen_string_literal: true

describe Catalog::ShowToolsComponent, type: :component do
  include ViewComponent::TestHelpers
  include ViewComponent::SystemTestHelpers

  let(:user) { nil }
  let(:document) { SolrDocument.new('field' => ['show value'], 'id' => 'test-document') }
  let(:component) { described_class.new(document: document) }
  let(:view_context) { vc_test_controller.view_context }

  before do
    with_controller_class(CatalogController) do
      sign_in user if user
      vc_test_controller.request.path_parameters[:controller] = 'catalog'
      vc_test_controller.instance_variable_set(:@document, document)
      allow(vc_test_controller).to receive_messages(view_context: view_context)
      allow(vc_test_controller).to receive(:render_ris_action?).and_return(true)
      allow(vc_test_controller.view_context).to receive(:ris_path).and_return('/catalog/test-document.ris')
      render_inline component
    end
  end

  it 'renders bookmark tool outside of dropdown' do
    href = Rails.application.routes.url_helpers.bookmark_path(document)
    expect(page).to have_css("div.btn-toolbar div.btn-group form.bookmark-toggle[action='#{href}']")
  end

  it 'renders the dropdown button' do
    expect(page).to have_css('div.btn-toolbar button.dropdown-toggle[data-bs-toggle="dropdown"]',
                             text: I18n.t('blacklight.tools.title'))
  end

  it 'renders the dropdown menu' do
    expect(page).to have_css('div.dropdown-menu[aria-labelledby="document-tools-dropdown"]')
  end

  it 'renders ris link' do
    expect(page).to have_css(".dropdown-menu a[href='/catalog/test-document.ris']",
                             text: I18n.t('blacklight.tools.ris'))
  end

  it 'renders citation link' do
    href = Rails.application.routes.url_helpers.citation_solr_document_path(document)
    expect(page).to have_css(".dropdown-menu a[href='#{href}']", text: I18n.t('blacklight.tools.citation'))
  end

  it 'renders staff view link' do
    href = Rails.application.routes.url_helpers.staff_view_solr_document_path(document)
    expect(page).to have_css(".dropdown-menu a[href='#{href}']", text: I18n.t('blacklight.tools.staff_view'))
  end

  context 'with link to email record' do
    context 'with a logged in user' do
      let(:user) { create(:user) }

      it 'renders link to email record' do
        href = Rails.application.routes.url_helpers.email_solr_document_path(document)
        expect(page).to have_css(".dropdown-menu a[href='#{href}']", text: I18n.t('blacklight.tools.email'))
      end
    end

    context 'without a logged in user' do
      it 'renders link to login' do
        href = Rails.application.routes.url_helpers.login_path(id: document.id)
        expect(page).to have_css(".dropdown-menu a[href='#{href}']", text: I18n.t('blacklight.tools.login_for_email'))
      end
    end
  end
end
