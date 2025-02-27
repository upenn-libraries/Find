# frozen_string_literal: true

FactoryBot.define do
  factory :ils_loan, class: 'Shelf::Entry::IlsLoan' do
    data { attributes_for(:alma_loan, :renewable) }

    trait :not_renewable do
      data { attributes_for(:alma_loan, :not_renewable) }
    end

    trait :resource_sharing do
      data { attributes_for(:alma_loan, :not_renewable, :resource_sharing) }
    end

    trait :borrow_direct do
      data { attributes_for(:alma_loan, :not_renewable, :borrow_direct) }
    end

    trait :boundwith do
      data { attributes_for(:alma_loan, :renewable, :boundwith) }
    end

    trait :overdue do
      data { attributes_for(:alma_loan, :overdue) }
    end

    trait :due_in_five_days do
      data { attributes_for(:alma_loan, due_date: 5.days.since.utc.iso8601) }
    end

    trait :due_in_ten_days do
      data { attributes_for(:alma_loan, due_date: 10.days.since.utc.iso8601) }
    end

    skip_create
    initialize_with { Shelf::Entry::IlsLoan.new(data.deep_stringify_keys) }
  end
end
