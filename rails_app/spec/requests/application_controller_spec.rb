# frozen_string_literal: true

describe 'Application Controller Requests' do
  include Alma::ApiMocks::User

  context 'when storing current location in the session' do
    let(:params) { {} }
    let(:stored_path) { session['user_return_to'] }

    context 'with a non catalog path' do
      let(:user) { create(:user) }
      let(:params) do
        { requesttype: '', booktitle: '', au: 'Margaret Mitchell' }
      end

      include_context 'with mocked illiad_record on user'

      before do
        stub_alma_user_find_success(id: user.uid, response_body: create(:alma_user_response))
        sign_in user
        get ill_new_request_path(params)
      end

      it 'stores the fullpath without removing blank parameters' do
        expect(stored_path).to eq ill_new_request_path(params)
      end
    end

    context 'with a catalog path with basic search parameters' do
      let(:params) do
        { search_field: 'all_fields', q: '', f: { access_facet: ['At the library'] },
          hld_id: 'holding id', request: true, sort: 'creator_sort asc, score desc', rows: '', per_page: '' }
      end

      before { get search_catalog_path(params) }

      it 'removes blank parameters from the path stored in session' do
        expect(stored_path).to eq search_catalog_path(params.compact_blank)
      end
    end

    context 'with a catalog path with advanced search parameters' do
      let(:params) do
        { sort: 'creator_sort asc, score desc', op: 'must', f_inclusive: { access_facet: ['At the library'] },
          clause: {
            '0' => { field: 'all_fields_advanced', query: '' },
            '1' => { field: 'creator_search', query: '' },
            '6' => { field: 'language_search', query: 'Swahili' },
            '15' => { field: 'publication_date_s', query: '' }
          } }
      end

      before { get search_catalog_path(params) }

      it "does not remove the 'all_fields_advanced' clause parameter from the path stored in the session" do
        expect(stored_path).to include 'all_fields_advanced'
      end

      it 'removes clause parameters without query values from the path stored in the session' do
        expect(stored_path).not_to include('creator_search', 'publication_date_s')
      end

      it 'stores the expected path in the session' do
        expect(stored_path).to eq '/catalog?clause%5B0%5D%5Bfield%5D=all_fields_advanced&clause%5B0%5D%5Bquery%5D='\
                                    '&clause%5B6%5D%5Bfield%5D=language_search&clause%5B6%5D%5Bquery%5D=Swahili'\
                                    '&f_inclusive%5Baccess_facet%5D%5B%5D=At+the+library&op=must'\
                                    '&sort=creator_sort+asc%2C+score+desc'
      end
    end

    context 'when the path is too large' do
      let(:params) { { q: ('a' * ApplicationController::MAX_PATH_SIZE_TO_STORE) } }

      before { get search_catalog_path(params) }

      it 'does not store it in the session' do
        expect(stored_path).to be_nil
      end
    end
  end
end
