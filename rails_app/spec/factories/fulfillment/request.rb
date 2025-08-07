# frozen_string_literal: true

FactoryBot.define do
  factory :fulfillment_request, class: 'Fulfillment::Request' do
    requester { build(:user) }

    trait :with_bib_info do
      title { 'Unowned Thing' }
      author { 'Obscure Author' }
      publisher { 'selfpublish.co' }
    end

    trait :with_item do
      with_bib_info
      mms_id { '1234' }
      holding_id { '5678' }
      item_id { '9999' }
    end

    trait :with_holding do
      with_bib_info
      mms_id { '1234' }
      holding_id { '5678' }
    end

    trait :with_section do
      with_bib_info
      pages { '1-999' }
      author { 'Hubbard, L.R.' }
    end

    trait :with_comments do
      comments { 'A very important comment.' }
    end

    trait :with_boundwith do
      boundwith { 'true' }
    end

    trait :proxied do
      proxy_for { 'jdoe' }
    end

    # BBM will come from Item Request form on show OR Illiad form page and go into Illiad
    trait :books_by_mail do
      delivery { Fulfillment::Options::Deliverable::MAIL }
    end

    # Office delivery (FacultyExpress) will come via Item Request for or Illiad form and go into Illiad
    trait :office_delivery do
      delivery { Fulfillment::Options::Deliverable::OFFICE }
    end

    trait :pickup do
      delivery { Fulfillment::Options::Deliverable::PICKUP }
      pickup_location { 'VanPeltLib' }
    end

    trait :ill_pickup do
      delivery { Fulfillment::Options::Deliverable::ILL_PICKUP }
      pickup_location { 'VanPeltLib' }
    end

    # ScanDeliver will come from ILL for or Item Request form and go into Illiad
    trait :scan_deliver do
      delivery { Fulfillment::Options::Deliverable::ELECTRONIC }
    end

    trait :illiad do
      endpoint { :illiad }
    end

    trait :docdel do
      delivery { Fulfillment::Options::Deliverable::DOCDEL }
    end

    skip_create
    initialize_with { Fulfillment::Request.new(**attributes) }
  end
end
