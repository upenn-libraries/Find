# frozen_string_literal: true

describe BreadcrumbsComponent, type: :components do
  let(:crumbs) { [] }
  let(:rendered) { render_inline(described_class.new(crumbs: crumbs)) }
  let(:labels) { rendered.css('.pl-crumb').map { |crumb| crumb.text.strip } }

  context 'with crumbs from the page' do
    let(:crumbs) { [{ label: 'Account', href: '/account' }, { label: 'Fines' }] }

    it 'opens with Penn Libraries and this app, then the crumbs the page added' do
      expect(labels).to eq [I18n.t('breadcrumbs.home'), I18n.t('breadcrumbs.root'), 'Account', 'Fines']
      expect(rendered).to have_link(I18n.t('breadcrumbs.root'), href: '/')
    end

    it 'marks the crumb without an href as the current page' do
      expect(rendered.css('[aria-current="page"]').text.strip).to eq 'Fines'
    end
  end

  context 'with no crumbs from the page, as on the home page' do
    it 'still opens the trail, with this app as the current page' do
      expect(labels).to eq [I18n.t('breadcrumbs.home'), I18n.t('breadcrumbs.root')]
      expect(rendered).to have_no_link(I18n.t('breadcrumbs.root'))
    end
  end
end
