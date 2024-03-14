# frozen_string_literal: true

module Inventory
  class Sort
    # Sorts electronic holdings data retrieved from Alma Availability API call
    class Electronic < Inventory::Sort
      BASE_SCORE = 0
      SERVICES_MAP = { collection: {
                         'Publisher website' => 100,
                         'The New Republic Archive' => 99,
                         'Publishers Weekly Archive (1872- current)' => 98,
                         'American Association for the Advancement of Science' => 97,
                         'Vogue Magazine Archive' => 96,
                         'ProQuest Historical Newspapers: The New York Times' => 95,
                         'ProQuest Historical Newspapers: Pittsburgh Post-Gazette' => 94,
                         'ProQuest Historical Newspapers: The Washington Post' => 93,
                         'Wiley Online Library - Current Journals' => 88,
                         'Academic OneFile' => 87,
                         'Academic Search Premier' => 86,
                         'LexisNexis Academic' => -1,
                         'Factiva' => -2,
                         'Gale Cengage GreenR' => -3,
                         'Nature Free' => -4,
                         'DOAJ Directory of Open Access Journals' => -5,
                         'Highwire Press Free' => -6,
                         'Biography In Context' => -7

                       },
                       interface: {
                         'Highwire Press' => 92,
                         'Elsevier ScienceDirect' => 91,
                         'Nature' => 90,
                         'Elsevier ClinicalKey' => 89
                       } }.freeze

      # Sorts electronic holdings ('portfolios') in descending order using legacy sorting scheme.
      # First sorts using services mapping, breaking any ties by sorting collection name in alphabetical order.
      # @return [Array]
      def sort
        holdings.sort_by { |holding| [Put.desc(service_score(holding)), Put.asc(holding['collection'])] }
      end

      private

      # Retrieve maximum score from services mapping. Returns base score if collection and interface are not in
      # services mapping.
      # @param [Hash] data
      # @return [Integer]
      def service_score(data)
        collection = data['collection']
        collection_score = SERVICES_MAP[:collection][collection]
        interface = data['interface_name']
        interface_score = SERVICES_MAP[:interface][interface]

        [collection_score, interface_score].compact.max || BASE_SCORE
      end
    end
  end
end
