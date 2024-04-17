# frozen_string_literal: true

module Broker
  class Backend
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
    class Illiad < Backend

      OFFICE_DELIVERY = 'office'
      MAIL_DELIVERY = 'mail'
      ELECTRONIC_DELIVERY = 'electronic'

      def submit(request:)
        body = submission_body_from request
        find_or_create(user: request.user) # user is an app User, which may eventually respond to `illiad_record`
        transaction = ::Illiad::Request.submit data: body
        add_notes(request, transaction) # notes require confirmation (transaction) number
        Outcome.new(
          # confirmation_number: request.id
        )
      end

      def find_or_create(user:)
        ::Illiad::User.find(id: user.id)
      rescue ::Illiad::Client::Error => _e # exception used in normal flow :/
        create_illiad_user_from(user)
      end

      def create_illiad_user_from(user)
        alma_user = user.alma_record
        attributes = { 'Username' => user.id,
                       'LastName' => alma_user.last_name,
                       'FirstName' => alma_user.first_name,
                       'EMailAddress' => alma_user.email,
                       'SSN' => alma_user.id,
                       'NVTGC' => 'VPL',
                       'Status' => alma_user.user_group,
                       'Department' => alma_user.affiliation,
                       'PlainTextPassword' => ENV['ILLIAD_USER_PASSWORD'], # TODO: where to store this?
                       'Address' => '',
                       'DeliveryMethod' => 'Mail to Address',
                       'Cleared' => 'Yes',
                       'Web' => true,
                       'ArticleBillingCategory' => 'Exempt',
                       'LoanBillingCategory' => 'Exempt' }
        ::Illiad::User.create(data: attributes) # This could raise...
      end

      def submission_body_from(request)
        if request.fulfillment_params[:delivery] == ELECTRONIC_DELIVERY
          scandelivery_request_body(request.user.id) # TODO: how to ensure all data is provided here? Ideally it would all be in request.item_parameters
        else
          body = book_request_body(request.user.id)
          append_routing_info(body)
        end
      end

      def add_notes(request, transaction)
        number = request[:TransactionNumber]
        note = request.fulfillment_parameters[:note]
        note += " - comment submitted by #{request.user.id}"
        ::Illiad::Request.add_note(id: number, note: note) # TODO: do we need to specify NOTE_TYPE in the POST body? See https://gitlab.library.upenn.edu/franklin/discovery-app/-/blob/master/lib/illiad/api_client.rb?ref_type=heads#L124
      end

      def book_request_body(user_id, item, data)
        body = {
          Username: user_id,
          RequestType: 'Loan',
          ProcessType: 'Borrowing',
          DocumentType: 'Book',
          LoanAuthor: item&.bib('author'),
          LoanTitle: item&.bib('title') || data[:bib_title],
          LoanPublisher: item&.bib('publisher_const'),
          LoanPlace: item&.bib('place_of_publication'),
          LoanDate: item&.bib('date_of_publication'),
          Location: item.temp_aware_location_display,
          CallNumber: item.temp_aware_call_number,
          ISSN: item&.bib('issn') || item&.bib('isbn') || data[:isxn],
          CitedIn: cited_in_value,
          ItemInfo3: item.barcode,
        }
        append_routing_info body
      end

      def scandelivery_request_body(user_id, item, data)
        {
          Username: user_id,
          ProcessType: 'Borrowing',
          DocumentType: 'Article',
          PhotoJournalTitle: item&.bib('title') || data[:bib_title],
          PhotoJournalVolume: data[:section_volume],
          PhotoJournalIssue: data[:section_issue],
          PhotoJournalMonth: item&.pub_month,
          PhotoJournalYear: item.try(:pub_year),
          PhotoJournalInclusivePages: data['section_pages'],
          ISSN: item&.bib('issn') || item&.bib('isbn') || data[:isxn],
          PhotoArticleAuthor: data[:section_author],
          PhotoArticleTitle: data[:section_title],
          CitedIn: 'info:sid/library.upenn.edu' # I made this up - it used to be 'info:sid/primo.exlibrisgroup.com'
        }
      end

      # See class level docs above
      def append_routing_info(body)
        if @data[:delivery] == MAIL_DELIVERY
          # BBM attribute changes to trigger Illiad routing rules
          body[:LoanTitle] = body[:LoanTitle].prepend('BBM ')
          body[:ItemInfo1] = 'Books by Mail'
        elsif @data[:delivery] == OFFICE_DELIVERY
          # Also set ItemInfo1 to BBM for Office delivery
          # It doesn't make sense, but this is what Lapis desires
          body[:ItemInfo1] = 'Books by Mail'
        end
        body
      end
    end
  end
end
