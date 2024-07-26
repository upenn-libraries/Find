# frozen_string_literal: true

module Fulfillment
  class Endpoint
    # Illiad submission backend
    # Submission here is complicated due to a number of Penn-specific practices.
    # 1. User creation - An Illiad submission is our de facto means of adding new users to Illiad. This means that
    #    prior to submitting a request, we have to ensure that the User has an Illiad account. IF they don't, we have
    #    to create one, then submit the request.
    # 2. Special case processing (FacultyExpress, Books by Mail) - due to staff workflows and other mysterious reasons,
    #    physical fulfillment of Penn-held items is managed by staff through Illiad. Some of this doesn't much make
    #    sense - but both BBM and FacEx are handled by special staff in Access Services, so the routing rules route to
    #    these staff based on the value added in the `ItemInfo1` field.
    #      i. Books by Mail - In order for Illiad to route these requests properly, we append 'BBM ' to the title field
    #         and place 'Books by Mail' in the `ItemInfo1` field of the request.
    #      ii. FacultyExpress - To route a FacultyExpress request, we just add the 'Books by Mail' text to the
    #          `ItemInfo1` field.
    class Illiad < Endpoint
      class UserError < StandardError; end

      CITED_IN = 'info:sid/library.upenn.edu'
      BASE_USER_ATTRIBUTES = { NVTGC: 'VPL', Address: '', DeliveryMethod: 'Mail to Address', Cleared: 'Yes',
                               ArticleBillingCategory: 'Exempt', LoanBillingCategory: 'Exempt' }.freeze
      BASE_TRANSACTION_ATTRIBUTES = { ProcessType: 'Borrowing' }.freeze
      BOOKS_BY_MAIL = 'Books by Mail'
      BOOKS_BY_MAIL_PREFIX = 'BBM'

      class << self
        # @param request [Request]
        # @return [Fulfillment::Outcome]
        def submit(request:)
          find_or_create user: request.patron
          body = BASE_TRANSACTION_ATTRIBUTES.merge(submission_body_from(request))
          transaction = ::Illiad::Request.submit data: body
          add_comment_note(request, transaction)
          add_proxy_note(request, transaction)
          add_boundwith_note(request, transaction)
          Outcome.new(request: request, confirmation_number: "ILLIAD_#{transaction.id}")
        end

        # @param request [Request]
        # @return [Array]
        def validate(request:)
          scope = %i[fulfillment validation]
          errors = []
          errors << I18n.t(:no_user_id, scope: scope) if request.patron&.uid.blank?
          errors << I18n.t(:no_courtesy_borrowers, scope: scope) if request.patron&.courtesy_borrower?
          errors << I18n.t(:no_proxy_requests, scope: scope) if request.proxied? && !request.requester.library_staff?
          errors << I18n.t(:proxy_invalid, scope: scope) if request.proxied? && !request.patron.alma_record?
          errors
        end

        private

        # @param request [Request]
        # @return [Hash]
        def submission_body_from(request)
          if request.scan?
            scandelivery_request_body(request)
          else
            body = book_request_body(request)
            append_routing_info(body, request)
          end
        end

        # @param [User] user
        # @return [Illiad::User, FalseClass]
        def find_or_create(user:)
          return user.illiad_record if user.illiad_record

          create_illiad_user(user)
        end

        # @param user [User]
        # @return [Illiad::User]
        def create_illiad_user(user)
          attributes = BASE_USER_ATTRIBUTES.merge(user_request_body(user))
          ::Illiad::User.create(data: attributes)
        rescue ::Illiad::Client::Error => e
          raise UserError, "Problem creating Illiad user: #{e.message}"
        end

        # Add note with comment contents.
        # @param request [Request]
        # @param transaction [::Illiad::Request]
        # @return [Hash]
        def add_comment_note(request, transaction)
          return if request.params.comments.blank?

          note = I18n.t('fulfillment.illiad.comment', comment: request.params.comments, user_id: request.requester.uid)
          add_note(transaction, note)
        end

        # Add note informing staff who is proxying this request.
        # @param request [Request]
        # @param transaction [::Illiad::Request]
        # @return [Hash]
        def add_proxy_note(request, transaction)
          return unless request.proxied?

          note = I18n.t('fulfillment.illiad.proxy_comment', requester_id: request.requester.uid)
          add_note(transaction, note)
        end

        # Add note informing staff if requested record is a boundwith
        # @param request [Request]
        # @param transaction [::Illiad::Request]
        # @return [Hash]
        def add_boundwith_note(request, transaction)
          return unless request.params.boundwith?

          add_note(transaction, I18n.t('fulfillment.illiad.boundwith_comment'))
        end

        def add_note(transaction, note)
          ::Illiad::Request.add_note(id: transaction.id, note: note)
        end

        # @param [Request] request
        # @return [Hash{Symbol->String (frozen)}]
        def book_request_body(request)
          { Username: request.patron.uid,
            RequestType: ::Illiad::Request::LOAN,
            DocumentType: 'Book',
            LoanAuthor: request.params.author,
            LoanTitle: request.params.book_title,
            LoanPublisher: request.params.publisher,
            LoanPlace: request.params.place,
            LoanDate: request.params.date || request.params.year,
            LoanEdition: request.params.edition,
            Location: request.params.location,
            CallNumber: request.params.call_number,
            ISSN: request.params.isbn,
            ESPNumber: request.params.pmid,
            CitedIn: request.params.sid || CITED_IN,
            ItemInfo3: request.params.barcode }
        end

        # TODO: do we need special request body and/or type definition for "Book Chapter" and "Conference Paper"

        # @param [Request] request
        # @return [Hash{Symbol->String (frozen)}]
        def scandelivery_request_body(request)
          { Username: request.patron.uid,
            DocumentType: ::Illiad::Request::ARTICLE,
            PhotoJournalTitle: request.params.title,
            PhotoJournalVolume: request.params.volume,
            PhotoJournalIssue: request.params.issue,
            PhotoJournalMonth: request.params.month,
            PhotoJournalYear: request.params.date || request.params.year,
            PhotoJournalInclusivePages: request.params.pages,
            ISSN: request.params.issn || request.params.isbn,
            ESPNumber: request.params.pmid,
            PhotoArticleAuthor: request.params.author,
            PhotoArticleTitle: request.params.chapter_title || request.params.article,
            CitedIn: request.params.sid || CITED_IN }
        end

        # @note See class level docs above
        # @param [Hash] body
        # @param [Request] request
        # @return [Hash]
        def append_routing_info(body, request)
          if request.delivery == Request::Options::MAIL
            # Set "BBM" title prefix so requests are routes to BBM staff
            body[:LoanTitle] = "#{BOOKS_BY_MAIL_PREFIX} #{body[:LoanTitle]}"
            body[:ItemInfo1] = BOOKS_BY_MAIL
          elsif request.delivery == Request::Options::OFFICE
            # Set ItemInfo1 to BBM for Office delivery so requests are routed to FacEx staff
            body[:ItemInfo1] = BOOKS_BY_MAIL
          else
            # Otherwise, add pickup location to ItemInfo1
            body[:ItemInfo1] = request.pickup_location
          end
          body
        end

        # @param [User] user
        # @return [Hash{Symbol->Unknown}]
        def user_request_body(user)
          {
            Username: user.uid,
            LastName: user.alma_record.last_name,
            FirstName: user.alma_record.first_name,
            EMailAddress: user.email,
            SSN: user.alma_record.id,
            Status: user.ils_group_name,
            Department: user.alma_affiliation
          }
        end
      end
    end
  end
end
