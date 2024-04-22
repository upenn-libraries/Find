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

    allow(Inventory::Service).to receive(:full).with(satisfy { |d| d.fetch(:id) == print_journal_bib })
                                               .and_return(Inventory::Response.new(entries: print_journal_entries))
    allow(Inventory::Service).to receive(:brief).with(satisfy { |d| d.fetch(:id) == print_journal_bib })
                                                .and_return(Inventory::Response.new(entries: print_journal_entries))
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

    allow(Inventory::Service).to receive(:full).with(satisfy { |d| d.fetch(:id) == print_monograph_bib })
                                               .and_return(Inventory::Response.new(entries: print_monograph_entries))
    allow(Inventory::Service).to receive(:brief).with(satisfy { |d| d.fetch(:id) == print_monograph_bib })
                                                .and_return(Inventory::Response.new(entries: print_monograph_entries))
  end
end

# Index electronic database record in to Solr and return inventory when requested.
shared_context 'with electronic database record' do
  let(:electronic_db_bib) { '9977577951303681' }
  let(:electronic_db_entries) do
    [create(:resource_link_entry, id: '1', inventory_type: Inventory::Entry::RESOURCE_LINK,
                                  href: 'http://hdl.library.upenn.edu/1017/126017',
                                  description: 'Connect to resource')]
  end

  before do
    SampleIndexer.index 'electronic_database.json'

    allow(Inventory::Service).to receive(:full).with(electronic_db_bib)
                                               .and_return(Inventory::Response.new(entries: electronic_db_entries))
    allow(Inventory::Service).to receive(:brief).with(electronic_db_bib)
                                                .and_return(Inventory::Response.new(entries: electronic_db_entries))
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
    allow(Inventory::Service).to receive(:full).with(satisfy { |d| d.fetch(:id) == electronic_journal_bib })
                                               .and_return(Inventory::Response.new(entries: electronic_journal_entries))
    allow(Inventory::Service).to receive(:brief).with(satisfy { |d| d.fetch(:id) == electronic_journal_bib })
                                                .and_return(
                                                  Inventory::Response.new(entries: electronic_journal_entries.first(3))
                                                )
    # Mock extra calls to retrieve notes.
    details_params = { mms_id: electronic_journal_bib, portfolio_id: '2', collection_id: '1234' }
    details = instance_double(
      Inventory::ElectronicDetail, **details_params,
      notes: ['In this database, you may need to navigate to view your article.']
    )
    allow(Inventory::ElectronicDetail).to receive(:new).with(**details_params).and_return(details)
  end
end
