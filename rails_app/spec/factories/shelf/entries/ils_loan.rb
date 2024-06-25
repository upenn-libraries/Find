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

    skip_create
    initialize_with { Shelf::Entry::IlsLoan.new(data.deep_stringify_keys) }
  end
end
