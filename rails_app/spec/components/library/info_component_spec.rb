# frozen_string_literal: true

describe Library::InfoComponent, type: :components do
  include Library::Info::ApiMocks::Request

  let(:code) { 'TheLib' }
  let(:component) { described_class.new(library_code: code) }
  let(:rendered) { render_inline(component) }

  describe 'library hours display' do
    context 'when todays hours and hours calendar link are available' do
      include_context 'with a successful Library Info request', :with_all_info
      it_behaves_like 'renders Library Info todays hours and hours link', hours_present: true, link_present: true
    end

    context 'when only todays hours are available' do
      include_context 'with a successful Library Info request', :without_links
      it_behaves_like 'renders Library Info todays hours and hours link', hours_present: true, link_present: false
    end

    context 'when only the hours calendar link is available' do
      include_context 'with a successful Library Info request', :with_all_info, todays_hours: ''
      it_behaves_like 'renders Library Info todays hours and hours link', hours_present: false, link_present: true
    end

    context 'when no hours content is available' do
      include_context 'with a successful Library Info request'
      it_behaves_like 'renders Library Info todays hours and hours link', hours_present: false, link_present: false
    end
  end

  describe 'library address display' do
    context 'when a complete address is available' do
      include_context 'with a successful Library Info request', :with_all_info
      it_behaves_like 'generates expected Library Info address', expected_line_count: 3
    end

    context 'when no addess line 2 is available' do
      include_context 'with a successful Library Info request', :with_all_info, address2: ''
      it_behaves_like 'generates expected Library Info address', expected_line_count: 2
    end

    context 'when city, state, or zip is not available' do
      include_context 'with a successful Library Info request', :with_all_info, city: ''
      it_behaves_like 'generates expected Library Info address', expected_line_count: 2
    end

    context 'when address line 1 is not available' do
      include_context 'with a successful Library Info request', :with_all_info, address1: ''
      it_behaves_like 'generates expected Library Info address', expected_line_count: 0
    end

    context 'when a link to the library location map is available' do
      include_context 'with a successful Library Info request', :with_all_info

      it 'renders the correct url' do
        expect(rendered).to have_link(href: api_response[:google_maps])
      end

      it 'links the library address to the map' do
        expect(rendered).to have_selector('.library-address .maps-link p')
      end
    end

    context 'when a link to the library location map is not available' do
      include_context 'with a successful Library Info request', :without_links

      it 'does not link the address to a map' do
        expect(rendered).not_to have_selector('.library-address .maps-link p')
      end
    end
  end

  describe 'library phone display' do
    context 'when a library phone number is available' do
      include_context 'with a successful Library Info request', :with_all_info

      it 'renders the library phone number' do
        expect(rendered).to have_link(api_response[:phone], href: "tel:#{api_response[:phone]}")
      end
    end

    context 'when no library phone number is available' do
      include_context 'with a successful Library Info request'

      it 'does not render the library phone number' do
        expect(rendered).not_to have_selector('.library-phone')
      end
    end
  end

  describe 'library email display' do
    context 'when a library email address is available' do
      include_context 'with a successful Library Info request', :with_all_info

      it 'renders the library email address' do
        expect(rendered).to have_text(api_response[:email])
      end
    end

    context 'when no library email address is available' do
      include_context 'with a successful Library Info request'

      it 'does not render the library email address' do
        expect(rendered).not_to have_selector('.library-email')
      end
    end
  end

  describe 'library about location display' do
    context 'when a library website url is available' do
      include_context 'with a successful Library Info request', :with_all_info

      it 'renders a link to the library homepage' do
        expect(rendered).to have_link(I18n.t('library.info.about'), href: api_response[:url])
      end
    end

    context 'when no library website url is available' do
      include_context 'with a successful Library Info request'

      it 'does not render a link to the library homepage' do
        expect(rendered).not_to have_selector('.library-about')
      end
    end
  end

  context 'when no library information is available' do
    include_context 'with a failed Library Info request'

    it 'renders the apology message' do
      expect(rendered).to have_text(I18n.t('library.info.no_info'))
    end
  end
end
