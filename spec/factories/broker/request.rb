# frozen_string_literal: true

FactoryBot.define do
  factory :broker_request, class: 'Broker::Request' do
    skip_create
    initialize_with { Broker::Request.new(**attributes) }

    user { build(:user) }

    trait :with_item do
      item_parameters { { bib_id: '1234', holding_id: '5678', item_id: '9999' } }
    end

    trait :with_holding do
      item_parameters { { bib_id: '1234', holding_id: '5678' } }
    end

    trait :with_bib do
      item_parameters { { title: 'Unowned Thing', author: 'Obscure Author', publisher: 'selfpublish.co' } } # TODO: check ILL form mockup for fields
    end

    trait :with_section do
      item_parameters { { pages: '1-999', section_author: 'Hubbard, L.R.' } } # TODO: check ILL form mockup for fields
    end

    # BBM will come from Item Request form on show OR Illiad form page and go into Illiad
    trait :books_by_mail do
      fulfillment_options { { method: :home_delivery } }
    end

    # Office delivery (FacultyExpress) will come via Item Request for or Illiad form and go into Illiad
    trait :office_delivery do
      fulfillment_options { { method: :office_delivery } }
    end

    # Office delivery (FacultyExpress) will come via Item Request for or Illiad form and go into Illiad
    trait :aeon do
      fulfillment_options { { method: :aeon } }
    end

    # Pickup will come from Item Request form on show page OR ILL request form
    # Destination will be Alma if an Item ID or Holding ID is provided, otherwise Illiad
    trait :pickup do
      fulfillment_options { { method: :pickup, location: 'van_pelt' } }
    end

    # ScanDeliver will come from ILL for or Item Request form and go into Illiad
    trait :scan_deliver do
      fulfillment_options { { method: :electronic } }
    end
  end
end
