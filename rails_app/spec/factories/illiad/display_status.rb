# frozen_string_literal: true

FactoryBot.define do
  factory :illiad_display_status, class: 'Illiad::DisplayStatus' do
    sequence(:Id) { |n| n }
    add_attribute(:TransactionStatus) { 'Jim MW Processing' }
    add_attribute(:DisplayStatus) { 'In Process' }

    skip_create
    initialize_with { Illiad::DisplayStatus.new(**attributes) }
  end
end
