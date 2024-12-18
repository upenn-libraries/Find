# frozen_string_literal: true

module Inventory
  # Supplement Alma::BibItem with additional functionality
  class Item
    include Blacklight::Searchable

    delegate :blacklight_config, to: CatalogController

    # Instance methods to return representations of an Item as hashes, typically for fulfillment contexts.
    module Export
      # Submission parameters for loans (of a whole work) that can be passed to the ILL form as OpenParams or directly
      # to the request submission endpoint.
      #
      # @return [Hash]
      def loan_params
        { title: bib_data['title'],
          author: bib_data['author'],
          call_number: call_number,
          location: temp_aware_location_display,
          barcode: item_data['barcode'],
          mms_id: bib_data['mms_id'],
          publisher: bib_data['publisher_const'],
          date: bib_data['date_of_publication'],
          edition: bib_data['complete_edition'],
          volume: volume,
          issue: issue,
          isbn: bib_data['isbn'],
          issn: bib_data['issn'],
          boundwith: boundwith? }
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
          'rft.place': bib_data['place_of_publication'],
          'rft.pub': bib_data['publisher_const'],
          'rft.title': bib_data['title'],
          'rft.volume': volume }
      end

      # Additional parameters to be passed to the Aeon request form
      #
      # @return [Hash]
      def aeon_additional_params
        { CallNumber: call_number,
          ItemISxN: item_data['inventory_number'],
          ItemNumber: item_data['barcode'],
          ItemIssue: item_issue,
          Location: location.code,
          ReferenceNumber: bib_data['mms_id'],
          Site: location.aeon_site,
          SubLocation: location.aeon_sublocation }
      end

      # All parameters to be passed to the Aeon request form
      #
      # @return [Hash]
      def aeon_params
        aeon_open_params.merge(aeon_additional_params)
      end

      # @return [String]
      def temp_aware_location_display
        display = "#{location.raw_library_name} - #{location.raw_location_name}"
        display.prepend('(temp) ') if in_temp_location?
        display
      end

      private

      # Get the issue from the contained in related parts field - sometimes, the issue information is stored in
      # 773$g - this doesn't come in the Alma response bib_data, so we have to get it from the marc record.
      def item_issue
        document = search_service.fetch(bib_data['mms_id'])
        return if document.blank?

        document.contained_in_related_parts
      end

      # Default to no search state.
      def search_state
        nil
      end
    end
  end
end
