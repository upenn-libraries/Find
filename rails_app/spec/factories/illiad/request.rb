# frozen_string_literal: true

FactoryBot.define do
  factory :illiad_request, class: 'Illiad::Request' do
    sequence(:TransactionNumber) { |n| n }
    add_attribute(:Username) { 'testuser' }
    add_attribute(:ProcessType) { 'Borrowing' }
    add_attribute(:RequestType) { 'Article' }
    add_attribute(:TransactionStatus) { 'Jim MW Processing' }
    add_attribute(:TransactionDate) { '2024-03-24T10:06:14.653' }

    skip_create
    initialize_with { Illiad::Request.new(**attributes) }

    trait :loan do
      add_attribute(:RequestType) { 'Loan' }
      add_attribute(:LoanTitle) { 'Autobiography' }
      add_attribute(:LoanAuthor) { 'Random, Author' }
    end

    trait :books_by_mail do
      loan
      add_attribute(:LoanTitle) { 'BBM Autobiography' }
      add_attribute(:ItemInfo1) { Illiad::Request::BOOKS_BY_MAIL }
    end

    trait :scan do
      add_attribute(:PhotoJournalTitle) { 'A Journal: With A Long Title' }
      add_attribute(:PhotoArticleAuthor) { 'Random, Author' }
    end

    trait :cancelled do
      add_attribute(:TransactionStatus) { 'Cancelled By ILL Staff' }
    end

    # Factory for borrow direct loan that is marked as completed in Illiad
    trait :completed_borrow_direct_loan do
      loan
      add_attribute(:TransactionStatus) { 'Request Finished' }
      add_attribute(:SystemID) { 'Reshare:upennbd' }
      add_attribute(:ILLNumber) { 'PUBD-1234' }
    end
  end
end
