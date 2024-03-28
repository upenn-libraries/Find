# frozen_string_literal: true

FactoryBot.define do
  factory :illiad_request_set, class: 'Illiad::RequestSet' do
    transient do
      amount { 1 }
    end

    requests { FactoryBot.build_list(%i[illiad_loan_request_data illiad_request_scan_data].sample, amount) }

    skip_create
    initialize_with { Illiad::RequestSet.new(requests: requests) }
  end
end
