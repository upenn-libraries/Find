# frozen_string_literal: true

FactoryBot.define do
  factory :illiad_api_request_response, class: Hash do
    # attributes for Illiad Api version 1
    # use `add_attribute` to alleviate some of the ugliness when defining PascalCase fields using the shorthand. This is
    # equivalent to the shorthand method to define attributes used in other factories.
    sequence(:TransactionNumber) { |num| num }
    add_attribute(:Username) { nil }
    add_attribute(:RequestType) { nil }
    add_attribute(:LoanAuthor) { nil }
    add_attribute(:LoanTitle) { nil }
    add_attribute(:LoanPublisher) { nil }
    add_attribute(:LoanPlace) { nil }
    add_attribute(:LoanDate) { nil }
    add_attribute(:LoanEdition) { nil }
    add_attribute(:PhotoJournalTitle) { nil }
    add_attribute(:PhotoJournalVolume) { nil }
    add_attribute(:PhotoJournalIssue) { nil }
    add_attribute(:PhotoJournalMonth) { nil }
    add_attribute(:PhotoJournalYear) { nil }
    add_attribute(:PhotoJournalInclusivePages) { nil }
    add_attribute(:PhotoArticleAuthor) { nil }
    add_attribute(:PhotoArticleTitle) { nil }
    add_attribute(:CitedIn) { nil }
    add_attribute(:CitedTitle) { nil }
    add_attribute(:CitedDate) { nil }
    add_attribute(:CitedVolume) { nil }
    add_attribute(:CitedPages) { nil }
    add_attribute(:NotWantedAfter) { nil }
    add_attribute(:AcceptNonEnglish) { false }
    add_attribute(:AcceptAlternateEdition) { true }
    add_attribute(:ArticleExchangeUrl) { nil }
    add_attribute(:ArticleExchangePassword) { nil }
    add_attribute(:TransactionStatus) { 'Awaiting RAPID Request Sending' }
    add_attribute(:TransactionDate) { '2024-03-27T14:12:29.86' }
    add_attribute(:ISSN) { '01234567' }
    add_attribute(:ILLNumber) { nil }
    add_attribute(:ESPNumber) { '' }
    add_attribute(:LendingString) { nil }
    add_attribute(:BaseFee) { nil }
    add_attribute(:PerPage) { nil }
    add_attribute(:Pages) { nil }
    add_attribute(:DueDate) { nil }
    add_attribute(:RenewalsAllowed) { false }
    add_attribute(:SpecIns) { nil }
    add_attribute(:Pieces) { nil }
    add_attribute(:LibraryUseOnly) { nil }
    add_attribute(:AllowPhotocopies) { false }
    add_attribute(:LendingLibrary) { nil }
    add_attribute(:ReasonForCancellation) { nil }
    add_attribute(:CallNumber) { nil }
    add_attribute(:Location) { nil }
    add_attribute(:Maxcost) { nil }
    add_attribute(:ProcessType) { 'Borrowing' }
    add_attribute(:ItemNumber) { nil }
    add_attribute(:LenderAddressNumber) { nil }
    add_attribute(:Ariel) { false }
    add_attribute(:Patron) { nil }
    add_attribute(:PhotoItemAuthor) { nil }
    add_attribute(:PhotoItemPlace) { nil }
    add_attribute(:PhotoItemPublisher) { nil }
    add_attribute(:PhotoItemEdition) { nil }
    add_attribute(:DocumentType) { nil }
    add_attribute(:InternalAcctNo) { nil }
    add_attribute(:PriorityShipping) { nil }
    add_attribute(:Rush) { 'Regular' }
    add_attribute(:CopyrightAlreadyPaid) { 'No' }
    add_attribute(:WantedBy) { nil }
    add_attribute(:SystemID) { 'OCLC' }
    add_attribute(:ReplacementPages) { nil }
    add_attribute(:IFMCost) { nil }
    add_attribute(:CopyrightPaymentMethod) { nil }
    add_attribute(:ShippingOptions) { nil }
    add_attribute(:CCCNumber) { nil }
    add_attribute(:IntlShippingOptions) { nil }
    add_attribute(:ShippingAcctNo) { nil }
    add_attribute(:ReferenceNumber) { nil }
    add_attribute(:CopyrightComp) { nil }
    add_attribute(:TAddress) { nil }
    add_attribute(:TAddress2) { nil }
    add_attribute(:TCity) { nil }
    add_attribute(:TState) { nil }
    add_attribute(:TZip) { nil }
    add_attribute(:TCountry) { nil }
    add_attribute(:TFax) { nil }
    add_attribute(:TEMailAddress) { nil }
    add_attribute(:TNumber) { nil }
    add_attribute(:HandleWithCare) { false }
    add_attribute(:CopyWithCare) { false }
    add_attribute(:RestrictedUse) { false }
    add_attribute(:ReceivedVia) { nil }
    add_attribute(:CancellationCode) { nil }
    add_attribute(:BillingCategory) { nil }
    add_attribute(:CCSelected) { 'No' }
    add_attribute(:OriginalTN) { nil }
    add_attribute(:OriginalNVTGC) { nil }
    add_attribute(:InProcessDate) { nil }
    add_attribute(:InvoiceNumber) { nil }
    add_attribute(:BorrowerTN) { nil }
    add_attribute(:WebRequestForm) { nil }
    add_attribute(:TName) { nil }
    add_attribute(:TAddress3) { nil }
    add_attribute(:IFMPaid) { nil }
    add_attribute(:BillingAmount) { nil }
    add_attribute(:ConnectorErrorStatus) { nil }
    add_attribute(:BorrowerNVTGC) { nil }
    add_attribute(:CCCOrder) { nil }
    add_attribute(:ShippingDetail) { nil }
    add_attribute(:ISOStatus) { nil }
    add_attribute(:OdysseyErrorStatus) { nil }
    add_attribute(:WorldCatLCNumber) { nil }
    add_attribute(:Locations) { nil }
    add_attribute(:FlagType) { nil }
    add_attribute(:FlagNote) { nil }
    add_attribute(:CreationDate) { '2020-03-27T14:12:29.797' }
    add_attribute(:ItemInfo1) { 'test' }
    add_attribute(:ItemInfo2) { nil }
    add_attribute(:ItemInfo3) { nil }
    add_attribute(:ItemInfo4) { nil }
    add_attribute(:ItemInfo5) { nil }
    add_attribute(:SpecialService) { nil }
    add_attribute(:DeliveryMethod) { nil }
    add_attribute(:Web) { nil }
    add_attribute(:PMID) { nil }
    add_attribute(:DOI) { nil }
    add_attribute(:LastOverdueNoticeSent) { nil }
    add_attribute(:ExternalRequest) { nil }

    trait :loan do
      add_attribute(:RequestType) { 'Loan' }
      add_attribute(:LoanAuthor) { 'B Franklin' }
      add_attribute(:LoanTitle) { 'Autobiography' }
      add_attribute(:LoanPublisher) { 'Penn Press' }
      add_attribute(:LoanPlace) { 'Philadelphia PA' }
      add_attribute(:LoanDate) { '2020' }
      add_attribute(:LoanEdition) { nil }
    end

    trait :books_by_mail do
      loan
      add_attribute(:LoanTitle) { 'BBM Autobiography' }
      add_attribute(:ItemInfo1) { Fulfillment::Endpoint::Illiad::BOOKS_BY_MAIL }
    end

    trait :scan do
      add_attribute(:RequestType) { 'Article' }
      add_attribute(:PhotoJournalTitle) { 'A Journal: With A Long Title' }
      add_attribute(:PhotoJournalVolume) { 'v5' }
      add_attribute(:PhotoJournalIssue) { '2' }
      add_attribute(:PhotoJournalMonth) { nil }
      add_attribute(:PhotoJournalYear) { '2020' }
      add_attribute(:PhotoJournalInclusivePages) { '1-10' }
      add_attribute(:PhotoArticleAuthor) { '' }
      add_attribute(:PhotoArticleTitle) { 'Article Title' }
    end

    skip_create
    initialize_with { attributes }
  end
end
