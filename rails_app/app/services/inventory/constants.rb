# frozen_string_literal: true

module Inventory
  class Constants
    # Availability statuses returned by Alma API availability lookup
    AVAILABLE = 'available'
    CHECK_HOLDINGS = 'check_holdings'
    UNAVAILABLE = 'unavailable'
    ELEC_AVAILABLE = 'Available'
    ELEC_UNAVAILABLE = 'Not Available'

    # Values used to generate links to electronic items
    ERESOURCE_LINK_HOST = 'upenn.alma.exlibrisgroup.com'
    ERESOURCE_LINK_PATH = '/view/uresolver/01UPENN_INST/openurl'
    ERESOURCE_LINK_RFR_ID = 'info:sid/primo.exlibrisgroup.com'

    ELECTRONIC_TYPES = [List::ELECTRONIC, List::ECOLLECTION].freeze
  end
end
