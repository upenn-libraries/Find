# frozen_string_literal: true

FactoryBot.define do
  factory :illiad_request, class: 'Illiad::Request' do
    for_loan

    skip_create
    initialize_with { Illiad::Request.new(data: data) }
  end

  factory :illiad_item, class: 'Illiad::Request::Item' do
    for_loan

    skip_create
    initialize_with { Illiad::Request::Item.new(data: data.symbolize_keys) }
  end

  trait :for_loan do
    data { FactoryBot.build(:illiad_loan_request_data) }
  end

  trait :for_books_by_mail do
    data { FactoryBot.build(:illiad_books_by_mail_request_data) }
  end

  trait :for_scan do
    data { FactoryBot.build(:illiad_scan_request_data) }
  end
end
