# frozen_string_literal: true

module Shelf
  module Entry
    # Shelf entry for a transaction/request in Illiad.
    class IllTransaction < Base
      module Status
        FINISHED = 'Request Finished'
        CANCELLED = 'Cancelled by ILL Staff'
        CHECKED_OUT = 'Checked Out to Customer'
        DELIVERED_TO_WEB = 'Delivered to Web'
      end

      module Type
        ARTICLE = 'Article'
        LOAN = 'Loan'
      end

      # BorrowDirect system id
      BD_SYSTEM_ID = 'Reshare:upennbd'
      PDF_SCAN_LOCATION = 'https://illiad.library.upenn.edu/illiad/PDF/'

      attr_reader :request, :display_statuses

      delegate :id, :request_type, :date, :data, to: :request
      delegate :status, to: :request, prefix: true

      # @param [Illiad::Request] request
      # @param [Illiad:DisplayStatus::Set] display_statuses
      def initialize(request, display_statuses)
        @request = request
        @display_statuses = display_statuses
      end

      def title
        if loan?
          data[:LoanTitle]
        elsif scan?
          [data[:PhotoJournalTitle], data[:PhotoArticleTitle]].compact_blank.join(' | ')
        end
      end

      def author
        data[:LoanAuthor] || data[:PhotoArticleAuthor]
      end

      # Illiad transaction don't have the MMS ID of an item because in most cases we do no own it.
      def mms_id
        nil
      end

      def status
        # BorrowDirect requests are marked as finished in Illiad as soon as the request is shipped by BorrowDirect
        # Partners. Therefore to provide a more accurate status to users we are overriding the status provided by
        # Illiad to be more descriptive.
        if request_status == Status::FINISHED && data[:SystemID] == BD_SYSTEM_ID
          'Shipped by BorrowDirect Partner'
        else
          display_statuses.display_for(request_status)
        end
      end

      # @return [Time]
      def last_updated_at
        date
      end

      def borrow_direct_identifier
        return unless request_status == Status::FINISHED && data[:SystemID] == BD_SYSTEM_ID

        data[:ILLNumber]
      end

      # Returns the expiration date of scans when they are available to download.
      #
      # @return [String] expiration date
      def expiry_date
        return unless pdf_available?

        format_date(date + 21.days)
      end

      # Returns true if the pdf scan is available for download.
      def pdf_available?
        scan? && request_status == Status::DELIVERED_TO_WEB
      end

      # Chunked download of pdf scan.
      #
      # @example
      #   file = File.new
      #   transaction.pdf do |chunk, *|
      #     file.write(chunk)
      #   end
      def pdf(&block)
        raise 'PDF not available' unless pdf_available?

        Faraday.get("#{PDF_SCAN_LOCATION}#{id}.pdf") do |req|
          req.options.on_data = block
        end
      end

      def system
        ILL
      end

      def type
        :transaction
      end

      def ill_transaction?
        true
      end

      # @return [Boolean]
      def loan?
        (request_type == Type::LOAN) && (request_status != Status::DELIVERED_TO_WEB)
      end

      # Some scan requests never get toggled to "Article" status but do get the published to web status
      # @return [Boolean]
      def scan?
        (request_type == Type::ARTICLE) ||
          (request_type == Type::LOAN && request_status == Status::DELIVERED_TO_WEB)
      end

      # @return [Boolean]
      def books_by_mail?
        data[:ItemInfo1] == Fulfillment::Endpoint::Illiad::BOOKS_BY_MAIL
      end
    end
  end
end
