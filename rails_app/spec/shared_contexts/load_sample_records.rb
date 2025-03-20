# frozen_string_literal: true

######################################################################
# Shared contexts to index records in Solr and provide it's inventory.
######################################################################

# Index print journal record in to Solr and return inventory when requested.
shared_context 'with print journal record' do
  let(:print_journal_bib) { '991844363503681' }
  let(:print_journal_entries) do
    [create(:physical_entry, mms_id: print_journal_bib, availability: 'available', call_number: 'QD1 .C48',
                             holding_info: '1965-1971', inventory_type: 'physical')]
  end

  before do
    SampleIndexer.index 'print_journal.json'

    allow(Inventory::List).to receive(:full).with(satisfy { |d| d.fetch(:id) == print_journal_bib })
                                            .and_return(Inventory::List::Response.new(entries: print_journal_entries))
    allow(Inventory::List).to receive(:brief).with(satisfy { |d| d.fetch(:id) == print_journal_bib })
                                             .and_return(Inventory::List::Response.new(entries: print_journal_entries))
    # Mock extra call to retrieve notes for any holding
    allow(Inventory::Holding).to receive(:find).and_return(create(:holding))
  end
end

shared_context 'with print monograph record with 2 physical entries' do
  let(:print_monograph_bib) { '9913203433503681' }
  let(:print_monograph_entries) do
    [create(:physical_entry, mms_id: print_monograph_bib, availability: 'available', holding_id: '1234',
                             call_number: 'Oversize QL937 B646 1961', holding_info: 'first copy',
                             location_code: 'veteresov', inventory_type: 'physical'),
     create(:physical_entry, mms_id: print_monograph_bib, availability: 'available', holding_id: '5678',
                             call_number: 'Oversize QL937 B646 1961 copy 2', holding_info: 'second copy',
                             location_code: 'veteresov', inventory_type: 'physical')]
  end

  before do
    SampleIndexer.index 'print_monograph.json'

    allow(Inventory::List).to receive(:full).with(satisfy { |d| d.fetch(:id) == print_monograph_bib })
                                            .and_return(Inventory::List::Response.new(entries: print_monograph_entries))
    allow(Inventory::List).to receive(:brief).with(satisfy { |d| d.fetch(:id) == print_monograph_bib })
                                             .and_return(
                                               Inventory::List::Response.new(entries: print_monograph_entries)
                                             )
    # Mock extra call to retrieve notes for any holding
    allow(Inventory::Holding).to receive(:find).and_return(create(:holding))
  end
end

shared_context 'with print monograph with an entry with an alternate title' do
  let(:print_monograph_bib) { '998308333503681' }
  let(:print_monograph_entries) do
    [create(:physical_entry, mms_id: print_monograph_bib, availability: 'available', holding_id: '1234',
                             call_number: 'VP1234', holding_info: 'some holding information',
                             location_code: 'veteresov', inventory_type: 'physical')]
  end

  before do
    SampleIndexer.index 'print_monograph_with_alternate_title.json'

    allow(Inventory::List).to receive(:full).with(satisfy { |d| d.fetch(:id) == print_monograph_bib })
                                            .and_return(Inventory::List::Response.new(entries: print_monograph_entries))
    allow(Inventory::List).to receive(:brief).with(satisfy { |d| d.fetch(:id) == print_monograph_bib })
                                             .and_return(
                                               Inventory::List::Response.new(entries: print_monograph_entries)
                                             )
    # Mock extra call to retrieve notes for any holding
    allow(Inventory::Holding).to receive(:find).and_return(create(:holding))
  end
end

shared_context 'with print monograph record with an entry in a temp location' do
  let(:print_monograph_bib) { '9913203433503681' }
  let(:print_monograph_entries) do
    [create(:physical_entry, mms_id: print_monograph_bib, availability: 'available', holding_id: nil,
                             call_number: 'AB123 1996', location_code: 'vpnewbook',
                             inventory_type: 'physical'),
     create(:physical_entry, mms_id: print_monograph_bib, availability: 'available', holding_id: '1234',
                             call_number: 'AB123 1999', location_code: 'veteresov',
                             inventory_type: 'physical')]
  end

  before do
    SampleIndexer.index 'print_monograph.json'

    allow(Inventory::List).to receive(:full).with(satisfy { |d| d.fetch(:id) == print_monograph_bib })
                                            .and_return(Inventory::List::Response.new(entries: print_monograph_entries))
    allow(Inventory::List).to receive(:brief).with(satisfy { |d| d.fetch(:id) == print_monograph_bib })
                                             .and_return(
                                               Inventory::List::Response.new(entries: print_monograph_entries)
                                             )
    # Mock extra call to retrieve notes for any holding
    allow(Inventory::Holding).to receive(:find).and_return(create(:holding))
  end
end

shared_context 'with print monograph record with 9 physical entries' do
  let(:print_monograph_bib) { '9913203433503681' }
  let(:print_monograph_entries) { create_list(:physical_entry, 9, mms_id: print_monograph_bib) }

  before do
    SampleIndexer.index 'print_monograph.json'

    allow(Inventory::List).to receive(:full).with(satisfy { |d| d.fetch(:id) == print_monograph_bib })
                                            .and_return(Inventory::List::Response.new(entries: print_monograph_entries))
    allow(Inventory::List).to receive(:brief).with(satisfy { |d| d.fetch(:id) == print_monograph_bib })
                                             .and_return(Inventory::List::Response.new(entries: print_monograph_entries)
                                                                               .first(3))
    # Mock extra call to retrieve notes for any holding
    allow(Inventory::Holding).to receive(:find).and_return(create(:holding))
  end
end

# Index electronic database record in to Solr and return inventory when requested.
shared_context 'with electronic database record' do
  let(:electronic_db_bib) { '9977577951303681' }
  let(:electronic_db_entries) do
    [create(:resource_link_entry, id: '1', inventory_type: Inventory::List::RESOURCE_LINK,
                                  href: 'http://hdl.library.upenn.edu/1017/126017',
                                  description: 'Connect to resource')]
  end

  before do
    SampleIndexer.index 'electronic_database.json'

    allow(Inventory::List).to receive(:full).with(satisfy { |d| d.fetch(:id) == electronic_db_bib })
                                            .and_return(Inventory::List::Response.new(entries: electronic_db_entries))
    allow(Inventory::List).to receive(:brief).with(satisfy { |d| d.fetch(:id) == electronic_db_bib })
                                             .and_return(Inventory::List::Response.new(entries: electronic_db_entries))
  end
end

# Index electronic journal records in to Solr and return inventory when requested.
shared_context 'with electronic journal record with 4 electronic entries' do
  let(:electronic_journal_bib) { '9977047322103681' }
  let(:electronic_journal_entries) do
    [create(:electronic_entry, mms_id: electronic_journal_bib, activation_status: 'Available',
                               collection: 'Nature Publishing Journals', portfolio_pid: '1',
                               coverage_statement: 'Available from 1869 volume: 1 issue: 1.'),
     create(:electronic_entry, mms_id: electronic_journal_bib, activation_status: 'Available',
                               collection: 'Gale Academic OneFile', portfolio_pid: '2', collection_id: '1234',
                               coverage_statement: 'Available from 01/06/2000 until 12/23/2021.'),
     create(:electronic_entry, mms_id: electronic_journal_bib, activation_status: 'Available',
                               collection: 'Academic Search Premier', portfolio_pid: '3',
                               coverage_statement: 'Available from 06/05/1997 until 11/27/2015.'),
     create(:electronic_entry, mms_id: electronic_journal_bib, activation_status: 'Available',
                               collection: 'Agricultural & Environmental Science Collection', portfolio_pid: '4',
                               coverage_statement: 'Available from 01/04/1990. Most recent 1 year(s) not available.')]
  end

  before do
    SampleIndexer.index 'electronic_journal.json'

    # Mock request to render inventory in index and show pages.
    allow(Inventory::List).to receive(:full).with(satisfy { |d| d.fetch(:id) == electronic_journal_bib })
                                            .and_return(
                                              Inventory::List::Response.new(entries: electronic_journal_entries)
                                            )
    allow(Inventory::List).to receive(:brief).with(satisfy { |d| d.fetch(:id) == electronic_journal_bib })
                                             .and_return(
                                               Inventory::List::Response.new(
                                                 entries: electronic_journal_entries.first(3)
                                               )
                                             )
    # Mock extra calls to retrieve notes.
    details_params = { mms_id: electronic_journal_bib, portfolio_id: '2', collection_id: '1234' }
    details = instance_double(
      Inventory::Electronic, **details_params,
      notes: ['<strong>In this database, you may need to navigate to view your article.</strong>']
    )
    allow(Inventory::Electronic).to receive(:find).with(**details_params).and_return(details)
  end
end

shared_context 'with a conference proceedings record with 1 physical holding' do
  let(:conference_bib) { '9978940183503681' }
  let(:conference_entries) do
    [create(:physical_entry, mms_id: conference_bib, availability: 'available', call_number: 'U6 .A313',
                             inventory_type: 'physical')]
  end

  before do
    SampleIndexer.index 'conference.json'

    allow(Inventory::List).to receive(:full).with(satisfy { |d| d.fetch(:id) == conference_bib })
                                            .and_return(Inventory::List::Response.new(entries: conference_entries))
    allow(Inventory::List).to receive(:brief).with(satisfy { |d| d.fetch(:id) == conference_bib })
                                             .and_return(Inventory::List::Response.new(entries: conference_entries))
    # Mock extra call to retrieve notes for any holding
    allow(Inventory::Holding).to receive(:find).and_return(create(:holding, id: conference_entries.first.id))
  end
end

# Index electronic database record in to Solr and return incomplete inventory.
shared_context 'with electronic database record having a resource link entry but fails to retrieve Alma holdings' do
  let(:electronic_db_bib) { '9977577951303681' }
  let(:electronic_db_entries) do
    [create(:resource_link_entry, id: '1', inventory_type: Inventory::List::RESOURCE_LINK,
                                  href: 'http://hdl.library.upenn.edu/1017/126017',
                                  description: 'Connect to resource')]
  end

  before do
    SampleIndexer.index 'electronic_database.json'
    allow(Inventory::List).to receive(:full).with(satisfy { |d| d.fetch(:id) == electronic_db_bib })
                                            .and_return(
                                              Inventory::List::Response.new(entries: electronic_db_entries,
                                                                            complete: false)
                                            )
  end
end
