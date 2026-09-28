# frozen_string_literal: true

describe BreadcrumbsComponent, type: :components do
  let(:rendered) do
    render_inline(described_class.new) do |trail|
      trail.with_breadcrumb(href: '/account') { 'Account' }
      trail.with_breadcrumb { 'Fines' }
    end
  end

  it 'opens with links to Penn Libraries and to this app' do
    expect(rendered).to have_link(I18n.t('breadcrumbs.home'), href: I18n.t('urls.home'))
    expect(rendered).to have_link(I18n.t('breadcrumbs.root'), href: '/')
  end

  it 'reads as a trail, in order' do
    expect(rendered.css('li').map { |crumb| crumb.text.strip })
      .to eq [I18n.t('breadcrumbs.home'), I18n.t('breadcrumbs.root'), 'Account', 'Fines']
  end

  it 'marks the page you are on, and does not link it' do
    expect(rendered.css('[aria-current="page"]').text.strip).to eq 'Fines'
    expect(rendered).to have_no_link('Fines')
  end

  context 'with no crumbs from the page, as on the home page' do
    let(:rendered) { render_inline(described_class.new) }

    it 'still names Penn Libraries, with this app as the page you are on' do
      expect(rendered).to have_link(I18n.t('breadcrumbs.home'), href: I18n.t('urls.home'))
      expect(rendered).to have_no_link(I18n.t('breadcrumbs.root'))
    end
  end
end
