# frozen_string_literal: true

describe Inventory::Full::Entry::ResourceLinkComponent, type: :components do
  subject(:rendered) { render_inline(described_class.new(entry: entry)) }

  context 'with a Colenda 856 entry' do
    let(:entry) { create(:colenda_resource_link_entry) }

    it 'renders the full description' do
      expect(rendered).to have_text entry.description
    end

    it 'renders a call to action link to Colenda' do
      expect(rendered).to have_link I18n.t('inventory.online_cta'), href: entry.href
    end
  end
end
