# frozen_string_literal: true

# stub Alma gem to return availability_data from Alma::Bib.get_availability
shared_context 'with stubbed availability_data' do
  before do
    # stub Alma API gem availability response to return a double
    availability_double = instance_double(Alma::AvailabilityResponse)
    allow(Alma::Bib).to receive(:get_availability).and_return(availability_double)
    # stub response double to return the availability data we want it to
    allow(availability_double).to receive(:availability).and_return(availability_data)
  end
end

# stub Alma gem to return item_data from a call to Alma::Bib.find
shared_context 'with stubbed availability item_data' do
  before do
    # stub Alma API gem item lookup to return a double for an Alma::BibItemSet
    bib_item_set_double = instance_double(Alma::BibItemSet)
    allow(Alma::BibItem).to receive(:find).and_return(bib_item_set_double)
    bib_item_double = instance_double(Alma::BibItem)
    # stub the set to return our item double
    allow(bib_item_set_double).to receive(:items).and_return([bib_item_double])
    # stub the item_data for the Alma::BibItem object
    allow(bib_item_double).to receive(:item_data).and_return(item_data)
  end
end

shared_context 'with stubbed ecollections_data' do
  let(:ecollections_response) { { 'electronic_collection' => ecollections_data, 'total_record_count' => 1 } }
  before do
    allow(Alma::Bib).to receive(:get_ecollections).and_return(ecollections_response)
  end
end

shared_context 'with stubbed ecollection_data' do
  before do
    ecollection_double = instance_double(Alma::Electronic::Collection)
    allow(ecollection_double).to receive(:data).and_return(ecollection_data)
    allow(Alma::Electronic).to receive(:get).and_return(ecollection_double)
  end
end
