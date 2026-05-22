# frozen_string_literal: true

FactoryBot.define do
  factory :illiad_request, class: 'Illiad::Request' do
    sequence(:TransactionNumber) { |n| n }
    add_attribute(:Username) { 'testuser' }
    add_attribute(:ProcessType) { 'Borrowing' }
    add_attribute(:RequestType) { Shelf::Entry::IllTransaction::Type::ARTICLE }
    add_attribute(:TransactionStatus) { 'Jim MW Processing' }
    add_attribute(:TransactionDate) { '2024-03-24T10:06:14.653' }

    skip_create
    initialize_with { Illiad::Request.new(**attributes) }

    trait :loan do
      add_attribute(:RequestType) { Shelf::Entry::IllTransaction::Type::LOAN }
      add_attribute(:LoanTitle) { 'Autobiography' }
      add_attribute(:LoanAuthor) { 'Random, Author' }
    end

    trait :books_by_mail do
      loan
      add_attribute(:LoanTitle) { 'BBM Autobiography' }
      add_attribute(:ItemInfo1) { Fulfillment::Endpoint::Illiad::BOOKS_BY_MAIL }
    end

    trait :scan do
      add_attribute(:PhotoJournalTitle) { 'A Journal: With A Long Title' }
      add_attribute(:PhotoArticleTitle) { 'Chapter 1' }
      add_attribute(:PhotoArticleAuthor) { 'Random, Author' }
    end

    trait :scan_with_pdf_available do
      scan
      add_attribute(:TransactionStatus) { Shelf::Entry::IllTransaction::Status::DELIVERED_TO_WEB }
    end

    trait :loan_with_pdf_available do
      add_attribute(:RequestType) { Shelf::Entry::IllTransaction::Type::ARTICLE }
      add_attribute(:TransactionStatus) { Shelf::Entry::IllTransaction::Status::DELIVERED_TO_WEB }
      add_attribute(:LoanTitle) { 'Problems with RAPID delivery' }
      add_attribute(:LoanAuthor) { 'Cohen, Lapis' }
    end

    trait :cancelled do
      add_attribute(:TransactionStatus) { Shelf::Entry::IllTransaction::Status::CANCELLED }
    end

    # Factory for borrow direct loan that is marked as completed in Illiad
    trait :completed_borrow_direct_loan do
      loan
      add_attribute(:TransactionStatus) { Shelf::Entry::IllTransaction::Status::FINISHED }
      add_attribute(:SystemID) { Shelf::Entry::IllTransaction::BD_SYSTEM_ID }
      add_attribute(:ILLNumber) { 'PUBD-1234' }
    end
  end
end
