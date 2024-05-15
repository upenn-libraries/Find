# frozen_string_literal: true

FactoryBot.define do
  factory :ils_loan, class: 'Shelf::Entry::IlsLoan' do
    data { attributes_for(:alma_loan) }

    trait :borrow_direct do
      data { attributes_for(:alma_loan, :borrow_direct) }
    end

    skip_create
    initialize_with { Shelf::Entry::IlsLoan.new(data.deep_stringify_keys) }
  end
end
