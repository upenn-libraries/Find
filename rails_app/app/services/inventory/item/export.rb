module Inventory
  class Item
    # Instance methods to return representations of an Item as hashes, typically for fulfillment contexts.
    module Export
      # Submission parameters for loans (of a whole work) that can be passed to the ILL form as OpenParams or directly
      # to the request submission endpoint.
      #
      # @return [Hash]
      def loan_params
        { title: bib_data['title'],
          author: bib_data['author'],
          call_number: temp_aware_call_number,
          location: temp_aware_location_display,
          barcode: item_data['barcode'],
          mms_id: bib_data['mms_id'],
          publisher: bib_data['publisher_const'],
          date: bib_data['date_of_publication'],
          edition: bib_data['complete_edition'],
          volume: volume,
          issue: issue,
          isbn: bib_data['isbn'],
          issn: bib_data['issn'] }
      end

      # Submission params for a scan (or electronic) request for a part of a work that can be passed to the ILL form as
      # OpenParams or directly to the request submission endpoint.
      #
      # @return [Hash]
      def scan_params
        loan_params.except(:author, :date)
      end

      # Open URL parameters to be passed to the Aeon request form
      #
      # @return [Hash]
      def aeon_open_params
        { 'rft.au': bib_data['author'],
          'rft.date': bib_data['date_of_publication'],
          'rft.edition': bib_data['complete_edition'],
          'rft.isbn': bib_data['isbn'],
          'rft.issn': bib_data['issn'],
          'rft.issue': issue,
          'rft.place': bib_data['place_of_publication'],
          'rft.pub': bib_data['publisher_const'],
          'rft.title': bib_data['title'],
          'rft.volume': volume }
      end

      # Additional parameters to be passed to the Aeon request form
      #
      # @return [Hash]
      def aeon_additional_params
        { CallNumber: temp_aware_call_number,
          ItemISxN: item_data['inventory_number'],
          ItemNumber: item_data['barcode'],
          Location: location,
          ReferenceNumber: bib_data['mms_id'],
          Site: aeon_site,
          SubLocation: aeon_sublocation }
      end

      # All parameters to be passed to the Aeon request form
      #
      # @return [Hash]
      def aeon_params
        aeon_open_params.merge(aeon_additional_params)
      end
    end
  end
end