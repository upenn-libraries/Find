# frozen_string_literal: true

FactoryBot.define do
  factory :illiad_display_status_set, class: 'Illiad::DisplayStatusSet' do
    display_statuses do
      [
        { TransactionStatus: 'Lapis Awaiting Consulting', DisplayStatus: 'In Process' },
        { TransactionStatus: 'Jim MW Processing', DisplayStatus: 'In Process' }
      ]
    end

    skip_create
    initialize_with { Illiad::DisplayStatusSet.new(**attributes) }
  end
end
