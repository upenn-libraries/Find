# frozen_string_literal: true

FactoryBot.define do
  factory :fulfillment_request, class: 'Fulfillment::Request' do
    skip_create
    initialize_with { Fulfillment::Request.new(**attributes) }
    params { ActionController::Parameters.new(item_parameters.merge(fulfillment_options)) }
    user { build(:user) }

    transient do
      item_parameters { {} }
      fulfillment_options { {} }
    end

    trait :with_item do
      item_parameters { { mms_id: '1234', holding_id: '5678', item_id: '9999' } }
    end

    trait :with_holding do
      item_parameters { { mms_id: '1234', holding_id: '5678' } }
    end

    trait :with_bib do
      item_parameters { { title: 'Unowned Thing', author: 'Obscure Author', publisher: 'selfpublish.co' } } # TODO: check ILL form mockup for fields
    end

    trait :with_section do
      item_parameters { { pages: '1-999', section_author: 'Hubbard, L.R.' } } # TODO: check ILL form mockup for fields
    end

    # BBM will come from Item Request form on show OR Illiad form page and go into Illiad
    trait :books_by_mail do
      fulfillment_options { { delivery: Fulfillment::Request::Options::HOME_DELIVERY } }
    end

    # Office delivery (FacultyExpress) will come via Item Request for or Illiad form and go into Illiad
    trait :office_delivery do
      fulfillment_options { { delivery: Fulfillment::Request::Options::OFFICE_DELIVERY } }
    end

    # Office delivery (FacultyExpress) will come via Item Request for or Illiad form and go into Illiad
    trait :aeon do
      fulfillment_options { { delivery: Fulfillment::Request::Options::AEON } }
    end

    # Pickup will come from Item Request form on show page OR ILL request form
    # Destination will be Alma if an Item ID or Holding ID is provided, otherwise Illiad
    trait :pickup do
      fulfillment_options { { delivery: Fulfillment::Request::Options::PICKUP, pickup_location: 'van_pelt' } }
    end

    # ScanDeliver will come from ILL for or Item Request form and go into Illiad
    trait :scan_deliver do
      fulfillment_options { { delivery: Fulfillment::Request::Options::ELECTRONIC_DELIVERY } }
    end
  end
end
