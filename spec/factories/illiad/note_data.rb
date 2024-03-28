# frozen_string_literal: true

FactoryBot.define do
  factory :illiad_note_data, class: Hash do
    add_attribute(:Id) { 1001 }
    add_attribute(:TransactionNumber) { 4567 }
    add_attribute(:NoteDate) { '2016-10-05T08:15:37.19' }
    add_attribute(:Note) { 'Sample Note' }
    add_attribute(:AddedBy) { 'Username' }
    add_attribute(:NoteType) { 'Staff' }

    skip_create
    initialize_with { attributes.stringify_keys }
  end
end
