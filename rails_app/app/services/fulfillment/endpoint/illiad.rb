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
    #    sense - but both BBM and FacEx are handles by special staff in Access Services, so the routing rules route to
    #    these staff based on the value added in the `ItemInfo1` field.
    #      i. Books by Mail - In order for Illiad to route these requests properly, we append 'BBM ' to the title field
    #         and place 'Books by Mail' in the `ItemInfo1` field of the request.
    #      ii. FacultyExpress - To route a FacultyExpress request, we just add the 'Books by Mail' test to the
    #          `ItemInfo1` field.
    class Illiad < Endpoint
      class UserError < StandardError; end

      CITED_IN = 'info:sid/library.upenn.edu'
      BASE_USER_ATTRIBUTES = { NVTGC: 'VPL', Address: '', DeliveryMethod: 'Mail to Address', Cleared: 'Yes', Web: true,
                               ArticleBillingCategory: 'Exempt', LoanBillingCategory: 'Exempt' }.freeze
      BASE_TRANSACTION_ATTRIBUTES = { ProcessType: 'Borrowing' }.freeze

      # These constants can probably live on the class that prepares the data we send
      # in our requests to Illiad
      BOOKS_BY_MAIL = 'Books by Mail'
      BOOKS_BY_MAIL_PREFIX = 'BBM'

      class << self
        def submit(request:)
          find_or_create user: request.user
          body = submission_body_from request
          transaction = ::Illiad::Request.submit data: body
          add_notes(request, transaction) if request.fulfillment_options[:note].present?
          Outcome.new(request: request, confirmation_number: "ILLIAD_#{transaction.id}",
                      item_desc: '', fulfillment_desc: '')
        end

        # @param [Request] request
        def validate(request:)
          errors = []
          errors << 'No user identifier provided' if request.user&.uid.blank?
          errors
        end

        private

        # @param [User] user
        def find_or_create(user:)
          return user.illiad_record if user.illiad_record

          create_illiad_user(user)
        end

        # @param [User] user
        def create_illiad_user(user)
          attributes = BASE_USER_ATTRIBUTES.merge(user_request_body(user))
          ::Illiad::User.create(data: attributes)
        rescue ::Illiad::Client::Error => e
          raise UserError, "Problem creating Illiad user: #{e.message}"
        end

        def submission_body_from(request)
          if request.fulfillment_options[:delivery] == Request::Options::ELECTRONIC_DELIVERY
            scandelivery_request_body(request)
          else
            body = book_request_body(request)
            append_routing_info(body, request)
          end
        end

        def add_notes(request, transaction)
          number = transaction.id
          note = request.fulfillment_options[:note]
          note += " - comment submitted by #{request.user.uid}"
          # TODO: do we need to specify NOTE_TYPE in the POST body? We do in Franklin
          ::Illiad::Request.add_note(id: number, note: note)
        end

        # @param [Request] request
        # @return [Hash{Symbol->String (frozen)}]
        def book_request_body(request)
          { Username: request.user.id,
            RequestType: ::Illiad::Request::LOAN,
            DocumentType: 'Book',
            LoanAuthor: request.item_parameters[:author],
            LoanTitle: request.item_parameters[:title],
            LoanPublisher: request.item_parameters[:publisher],
            LoanPlace: request.item_parameters[:place_published],
            LoanDate: request.item_parameters[:date_published],
            Location: request.item_parameters[:temp_aware_location_display],
            CallNumber: request.item_parameters[:temp_aware_call_number],
            ISSN: request.item_parameters[:issn] || request.item_parameters[:isbn] || request.item_parameters[:isxn],
            CitedIn: request.item_parameters[:sid] || CITED_IN,
            ItemInfo3: request.item_parameters[:barcode] }
        end

        # @param [Request] request
        # @return [Hash{Symbol->String (frozen)}]
        def scandelivery_request_body(request)
          { Username: request.user.id,
            DocumentType: ::Illiad::Request::ARTICLE,
            PhotoJournalTitle: request.item_parameters[:title],
            PhotoJournalVolume: request.scan_details[:volume],
            PhotoJournalIssue: request.scan_details[:issue],
            PhotoJournalMonth: request.item_parameters[:pub_month],
            PhotoJournalYear: request.item_parameters[:year],
            PhotoJournalInclusivePages: request.scan_details[:section_pages],
            ISSN: request.item_parameters[:issn],
            ESPNumber: request.item_parameters[:pmid],
            PhotoArticleAuthor: request.scan_details[:section_author],
            PhotoArticleTitle: request.scan_details[:section_title],
            CitedIn: request.item_parameters[:sid] || CITED_IN }
        end

        # @note See class level docs above
        # @param [Hash] body
        # @param [Request] request
        # @return [Hash]
        def append_routing_info(body, request)
          if request.fulfillment_options[:delivery] == Request::Options::HOME_DELIVERY
            # Set "BBM" title prefix so requests are routes to BBM staff
            body[:LoanTitle] = "#{BOOKS_BY_MAIL_PREFIX} #{body[:LoanTitle]}"
            body[:ItemInfo1] = BOOKS_BY_MAIL
          elsif request.fulfillment_options[:delivery] == Request::Options::OFFICE_DELIVERY
            # Set ItemInfo1 to BBM for Office delivery so requests are routed to FacEx staff
            body[:ItemInfo1] = BOOKS_BY_MAIL
          else
            # Otherwise, add pickup location to ItemInfo1
            body[:ItemInfo1] = request.fulfillment_options[:pickup_location]
          end
          body
        end

        # @param [User] user
        # @return [Hash{Symbol->Unknown}]
        def user_request_body(user)
          { Username: user.uid,
            LastName: user.alma_record.last_name,
            FirstName: user.alma_record.first_name,
            EMailAddress: user.alma_record.email,
            SSN: user.alma_record.id,
            Status: user.alma_record.user_group,
            Department: user.alma_record.affiliation,
            PlainTextPassword: Settings.illiad.user_password }
        end
      end
    end
  end
end
