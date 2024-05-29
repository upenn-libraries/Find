# frozen_string_literal: true

module Shelf
  module Entry
    # Shelf entry for a transaction/request in Illiad.
    class IllTransaction < Base
      attr_reader :request, :display_statuses

      delegate :id, to: :request

      # @param [Illiad::Request] request
      # @param [Illiad:DisplayStatus::Set] display_statuses
      def initialize(request, display_statuses)
        @request = request
        @display_statuses = display_statuses
      end

      def title
        request.data[:LoanTitle] || request.data[:PhotoJournalTitle]
      end

      def author
        request.data[:LoanAuthor] || request.data[:PhotoArticleAuthor]
      end

      # Illiad transaction don't have the MMS ID of an item because in most cases we do no own it.
      def mms_id
        nil
      end

      def status
        # BorrowDirect requests are marked as finished in Illiad as soon as the request is shipped by BorrowDirect
        # Partners. Therefore to provide a more accurate status to users we are overriding the status provided by
        # Illiad to be more descriptive.
        if request.status == Illiad::Request::FINISHED && request.data[:SystemID] == Illiad::Request::BD_SYSTEM_ID
          'Shipped by BorrowDirect Partner'
        else
          display_statuses.display_for(request.status)
        end
      end

      # @return [Time]
      def last_updated_at
        request.date
      end

      def borrow_direct_identifier
        return unless request.status == Illiad::Request::FINISHED &&
                      request.data[:SystemID] == Illiad::Request::BD_SYSTEM_ID

        request.data[:ILLNumber]
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
    end
  end
end
