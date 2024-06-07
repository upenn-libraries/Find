# frozen_string_literal: true

FactoryBot.define do
  factory :fulfillment_request, class: 'Fulfillment::Request' do
    skip_create
    initialize_with { Fulfillment::Request.new(**attributes) }
    params { raw_params.merge(fulfillment_params) }
    user { build(:user) }

    transient do
      raw_params { {} }
      fulfillment_params { {} }
    end

    trait :with_item do
      raw_params { { mms_id: '1234', holding_id: '5678', item_id: '9999' } }
    end

    trait :with_holding do
      raw_params { { mms_id: '1234', holding_id: '5678' } }
    end

    trait :with_bib do
      raw_params { { title: 'Unowned Thing', author: 'Obscure Author', publisher: 'selfpublish.co' } }
    end

    trait :with_section do
      raw_params { { pages: '1-999', section_author: 'Hubbard, L.R.' } }
    end

    # BBM will come from Item Request form on show OR Illiad form page and go into Illiad
    trait :books_by_mail do
      fulfillment_params { { delivery: Fulfillment::Request::Options::MAIL } }
    end

    # Office delivery (FacultyExpress) will come via Item Request for or Illiad form and go into Illiad
    trait :office_delivery do
      fulfillment_params { { delivery: Fulfillment::Request::Options::OFFICE } }
    end

    # trait :aeon do
    #   fulfillment_params { { delivery: Fulfillment::Request::Options::AEON } }
    # end

    trait :pickup do
      fulfillment_params { { delivery: Fulfillment::Request::Options::PICKUP, pickup_location: 'van_pelt' } }
    end

    trait :ill_pickup do
      fulfillment_params { { delivery: Fulfillment::Request::Options::ILL_PICKUP, pickup_location: 'van_pelt' } }
    end


    # ScanDeliver will come from ILL for or Item Request form and go into Illiad
    trait :scan_deliver do
      fulfillment_params { { delivery: Fulfillment::Request::Options::ELECTRONIC } }
    end
  end
end
