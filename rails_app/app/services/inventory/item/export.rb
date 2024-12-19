# frozen_string_literal: true

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
      # @return [String, nil]
      def item_issue
        return unless marc_record

        pennmarc.public_send(:relation_contained_in_related_parts_show, marc_record).join(' ')
      end

      # Get the Alma record for the bib_data mms_id. Making an additional call to Alma is the most convenient way to
      # retrieve the full MarcXML for the record.
      # @return [Alma::BibSet, nil]
      def alma_record
        alma_response = Alma::Bib.find([bib_data['mms_id']], {})&.response || {}
        return if alma_response.blank?

        @alma_record ||= alma_response['bib']&.first
      end

      # Extract the MarcXML from the Alma record and parse it into a MARC::Record
      # @return [MARC::Record, nil]
      def marc_record
        raw_xml = alma_record['anies']&.first
        return if raw_xml.blank?

        @marc_record ||= MARC::XMLReader.new(StringIO.new(raw_xml)).first
      end

      # @return [PennMARC::Parser]
      def pennmarc
        @pennmarc ||= PennMARC::Parser.new
      end
    end
  end
end
