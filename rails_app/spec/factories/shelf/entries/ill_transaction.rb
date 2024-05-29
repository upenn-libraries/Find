# frozen_string_literal: true

FactoryBot.define do
  factory :ill_transaction, class: 'Shelf::Entry::IllTransaction' do
    display_statuses { association :illiad_display_status_set }
    request { association :illiad_request, :loan }

    trait :completed_borrow_direct_loan do
      request { association :illiad_request, :completed_borrow_direct_loan }
    end

    skip_create
    initialize_with { Shelf::Entry::IllTransaction.new(request, display_statuses) }
  end
end
