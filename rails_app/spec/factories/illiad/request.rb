# frozen_string_literal: true

FactoryBot.define do
  factory :illiad_request, class: 'Illiad::Request' do
    sequence(:TransactionNumber) { |n| n }
    add_attribute(:Username) { 'testuser' }
    add_attribute(:ProcessType) { 'Borrowing' }
    add_attribute(:RequestType) { 'Article' }

    skip_create
    initialize_with { Illiad::Request.new(**attributes) }

    trait :loan do
      add_attribute(:RequestType) { 'Loan' }
      add_attribute(:LoanTitle) { 'Autobiography' }
    end

    trait :books_by_mail do
      loan
      add_attribute(:LoanTitle) { 'BBM Autobiography' }
      add_attribute(:ItemInfo1) { Fulfillment::Endpoint::Illiad::BOOKS_BY_MAIL }
    end

    trait :scan do
      add_attribute(:PhotoJournalTitle) { 'A Journal: With A Long Title' }
    end
  end
end
