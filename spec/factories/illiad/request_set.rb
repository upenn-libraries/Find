# frozen_string_literal: true

FactoryBot.define do
  factory :illiad_request_set, class: 'Illiad::RequestSet' do
    requests do
      [{ TransactionNumber: 1, ProcessType: 'Borrowing', RequestType: 'Article', Username: 'testuser' }]
    end

    skip_create
    initialize_with { Illiad::RequestSet.new(**attributes) }
  end
end
