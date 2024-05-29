# frozen_string_literal: true

FactoryBot.define do
  factory :alma_loan, class: 'Alma::Loan' do
    loan_id { Faker::Number.number(digits: 16).to_s }
    circ_desk { { 'value' => 'DEFAULT_CIRC_DESK', 'desc' => 'Van Pelt Circulation' } }
    return_circ_desk { {} }
    library { { 'value' => 'VanPeltLib', 'desc' => 'Van Pelt Library' } }
    user_id { '123456' }
    item_barcode { Faker::Barcode.ean(13) }
    due_date { 45.days.since.utc.iso8601 }
    loan_status { 'ACTIVE' }
    loan_date { '2021-08-16T22:46:53.670Z' }
    returned_by { { 'value' => '' } }
    process_status { 'RENEW' }
    mms_id { '9938978223503681' }
    holding_id { '22379246830003681' }
    item_id { '23379246820003681' }
    title { Faker::Book.title }
    author { Faker::Book.author }
    publication_year { Faker::Date.between(from: 1956, to: 2020).to_s }
    location_code { { 'value' => 'vanp', 'name' => 'Stacks' } }
    item_policy { { 'value' => 'book/seria', 'description' => 'Book/serial' } }
    call_number { 'PS3537.A426 C3 1979' }
    last_renew_status { { 'desc' => '' } }

    trait :renewable do
      renewable { true }
    end

    trait :not_renewable do
      renewable { false }
    end

    trait :renewed do
      last_renew_date { '2023-05-15T16:56:21.688Z' }
      last_renew_status { { 'value' => '401193;', 'desc' => 'Renewed Successfully' } }
    end

    trait :overdue do
      due_date { 5.days.ago.utc.iso8601 }
    end

    trait :resource_sharing do
      library { { 'value' => 'RES_SHARE', 'desc' => 'Resource Sharing Library' } }
      location_code { { 'value' => 'OUT_RS_REQ', 'name' => 'Out on Loan ' } }
      item_policy { { 'value' => 'bd', 'description' => 'Borrow Direct' } } # This value changes based on the system used.
    end

    trait :borrow_direct do
      resource_sharing
      item_barcode { 'PUBD-1234' }
    end

    skip_create
    initialize_with { Alma::Loan.new(attributes.deep_stringify_keys) }
  end
end
