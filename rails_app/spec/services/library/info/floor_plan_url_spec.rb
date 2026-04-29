# frozen_string_literal: true

describe Library::Info::FloorPlanUrl do
  let(:call_number) { nil }
  let(:location_code) { nil }
  let(:library_info) { Library::Info::Request.new(**build(:library_info_api_request_response, :with_all_info)) }
  let(:floor_plan_url) do
    described_class.new(library_info: library_info, call_number: call_number, location_code: location_code)
  end

  describe '#get' do
    context "with a location code matching one of its building's floors" do
      let(:location_code) { 'musicsem' }

      it "returns a link to the building's floor plan" do
        expect(floor_plan_url.get).to eq 'https://www.library.upenn.edu/floor-plans/van-pelt/fourth-floor'
      end
    end

    context "with a call number located on one of its building's floors" do
      let(:call_number) { 'MU101' }

      it "returns a link to the building's floor plan" do
        expect(floor_plan_url.get).to eq 'https://www.library.upenn.edu/floor-plans/van-pelt/fourth-floor'
      end
    end

    context 'without matching a particular floor plan' do
      let(:location_code) { 'unknown' }
      let(:call_number) { 'NA101' }

      it "returns a link to the building's floor plan landing page" do
        expect(floor_plan_url.get).to eq 'https://www.library.upenn.edu/floor-plans/van-pelt'
      end
    end

    context 'without any identifiable floor plans' do
      let(:library_info) { Library::Info::Request.new(**build(:library_info_api_request_response)) }

      it 'returns nil' do
        expect(floor_plan_url.get).to be_nil
      end
    end
  end
end
