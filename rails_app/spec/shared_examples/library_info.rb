# frozen_string_literal: true

shared_examples 'renders Library Info todays hours and hours link' do |hours_present:, link_present:|
  let(:todays_hours) { I18n.t('library.info.todays_hours', hours: api_response[:todays_hours]) }
  let(:hours_url) { api_response[:hours_url] }

  if hours_present
    it 'renders todays hours' do
      expect(rendered).to have_text(todays_hours)
    end
  else
    it 'does not render todays hours' do
      expect(rendered).not_to have_text(todays_hours)
    end
  end

  if link_present
    view_hours = hours_present ? I18n.t('library.info.view_more_hours') : I18n.t('library.info.view_hours')

    it 'renders the hours calendar link' do
      expect(rendered).to have_link(view_hours, href: hours_url)
    end
  else
    it 'does not render the hours calendar link' do
      expect(rendered).not_to have_link(href: hours_url)
    end
  end
end

shared_examples 'generates expected Library Info address' do |expected_line_count:|
  if expected_line_count.zero?
    it 'does not render the address block' do
      expect(rendered).not_to have_selector('.library-address')
    end
  else
    it "generates #{expected_line_count} library address lines" do
      expect(rendered).to have_selector('.library-address p', count: expected_line_count)
    end

    it 'generates expected library address line content' do
      address = component.send(:address_content)
      address.each do |line|
        expect(rendered).to have_selector('.library-address p', text: line)
      end
    end
  end
end