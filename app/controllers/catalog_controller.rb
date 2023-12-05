# frozen_string_literal: true

# Blacklight controller that handles searches and document requests
class CatalogController < ApplicationController
  include Blacklight::Catalog

  # This constant is used in the qf/pf params sent to Solr. These fields are those that are searched over when
  # performing a search.
  QUERY_FIELDS = %i[id creator_search title_search subject_search genre_search isxn_search].freeze

  # If you'd like to handle errors returned by Solr in a certain way,
  # you can use Rails rescue_from with a method you define in this controller,
  # uncomment:
  #
  # rescue_from Blacklight::Exceptions::InvalidRequest, with: :my_handling_method

  configure_blacklight do |config|
    ## Specify the style of markup to be generated (may be 4 or 5)
    # config.bootstrap_version = 5
    #
    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response
    #
    ## The destination for the link around the logo in the header
    # config.logo_link = root_path
    #
    ## Should the raw solr document endpoint (e.g. /catalog/:id/raw) be enabled
    # config.raw_endpoint.enabled = false

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    config.default_solr_params = {
      qt: 'search', qf: QUERY_FIELDS.join(' '), pf: QUERY_FIELDS.join(' ')
    }

    # solr path which will be added to solr base url before the other solr params.
    config.solr_path = 'select'
    config.document_solr_path = 'get'
    config.json_solr_path = 'advanced'

    # Display link to advanced search form
    config.advanced_search.enabled = true

    # items to show per page, each number in the array represent another option to choose from.
    config.per_page = [10, 20, 50, 100]

    # solr field configuration for search results/index views
    config.index.title_field = :title_ss
    # config.index.display_type_field = 'format'
    # config.index.thumbnail_field = 'thumbnail_path_ss'

    # The presenter is the view-model class for the page
    # config.index.document_presenter_class = MyApp::IndexPresenter

    # Some components can be configured
    # config.index.document_component = MyApp::SearchResultComponent
    # config.index.constraints_component = MyApp::ConstraintsComponent
    config.index.search_bar_component = Find::SearchBarComponent
    # config.index.search_header_component = MyApp::SearchHeaderComponent
    # config.index.document_actions.delete(:bookmark)

    config.add_results_document_tool(:bookmark, component: Blacklight::Document::BookmarkComponent,
                                                if: :render_bookmarks_control?)

    config.add_results_collection_tool(:sort_widget)
    config.add_results_collection_tool(:per_page_widget)
    config.add_results_collection_tool(:view_type_group)

    config.add_show_tools_partial(:bookmark, component: Blacklight::Document::BookmarkComponent,
                                             if: :render_bookmarks_control?)
    config.add_show_tools_partial(:email, callback: :email_action, validator: :validate_email_params)
    config.add_show_tools_partial(:sms, if: :render_sms_action?, callback: :sms_action, validator: :validate_sms_params)
    config.add_show_tools_partial(:citation)

    config.add_nav_action(:bookmark, partial: 'blacklight/nav/bookmark', if: :render_bookmarks_control?)
    config.add_nav_action(:search_history, partial: 'blacklight/nav/search_history')

    # solr field configuration for document/show views
    config.show.title_field = :title_ss
    # config.show.display_type_field = 'format'
    # config.show.thumbnail_field = 'thumbnail_path_ss'
    #
    # The presenter is a view-model class for the page
    # config.show.document_presenter_class = MyApp::ShowPresenter
    #
    # These components can be configured
    # config.show.document_component = MyApp::DocumentComponent
    # config.show.sidebar_component = MyApp::SidebarComponent
    # config.show.embed_component = MyApp::EmbedComponent

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    #
    # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically
    #   across a large set of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case
    #   sensitive when searching values)

    # Configure database facets

    # lambda to control database facets display
    database_selected = lambda { |controller, _config, _field|
      controller.params.dig(:f, :format_facet)&.include?('Database & Article Index')
    }

    config.add_facet_field :db_sub_subject_facet, label: I18n.t('facets.databases.subject'),
                                                  show: database_selected
    config.add_facet_field :db_type_facet, label: I18n.t('facets.databases.type'), show: database_selected

    # Configure general facets
    config.add_facet_field :access_facet, label: I18n.t('facets.access')
    config.add_facet_field :format_facet, label: I18n.t('facets.format'), limit: true
    config.add_facet_field :creator_facet, label: I18n.t('facets.creator'), limit: true
    config.add_facet_field :subject_facet, label: I18n.t('facets.subject'), limit: true
    config.add_facet_field :language_facet, label: I18n.t('facets.language'), limit: true
    config.add_facet_field :library_facet, label: I18n.t('facets.library'), limit: true
    config.add_facet_field :location_facet, label: I18n.t('facets.location'), limit: true
    config.add_facet_field :genre_facet, label: I18n.t('facets.genre'), limit: true

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field :creator_ss, label: I18n.t('results.creator')
    config.add_index_field :format_ss, label: I18n.t('results.format')

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field :title_show, label: I18n.t('show.title'), accessor: :marc
    config.add_show_field :creator_show, label: I18n.t('show.creator'), accessor: :marc
    config.add_show_field :format_show, label: I18n.t('show.format'), accessor: :marc
    config.add_show_field :edition_show, label: I18n.t('show.edition'), accessor: :marc
    config.add_show_field :series_show, label: I18n.t('show.series'), accessor: :marc
    config.add_show_field :subject_show, label: I18n.t('show.subject.all'), accessor: :marc
    config.add_show_field :subject_medical_show, label: I18n.t('show.subject.mesh'), accessor: :marc
    config.add_show_field :subject_local_show, label: I18n.t('show.subject.local'), accessor: :marc
    config.add_show_field :genre_show, label: I18n.t('show.genre'), accessor: :marc
    config.add_show_field :production_publication_show, label: I18n.t('show.place-of-publication'), accessor: :marc
    config.add_show_field :language_show, label: I18n.t('show.language'), accessor: :marc
    config.add_show_field :note_notes_show, label: I18n.t('show.notes'), accessor: :marc

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    config.add_search_field 'all_fields', label: I18n.t('search.all_fields') do |field|
      field.include_in_advanced_search = false
    end

    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    # config.add_search_field('title') do |field|
    #   # solr_parameters hash are sent to Solr as ordinary url query params.
    #   field.solr_parameters = {
    #     'spellcheck.dictionary': 'title',
    #     qf: '${title_qf}',
    #     pf: '${title_pf}'
    #   }
    # end

    # config.add_search_field('author') do |field|
    #   field.solr_parameters = {
    #     'spellcheck.dictionary': 'author',
    #     qf: '${author_qf}',
    #     pf: '${author_pf}'
    #   }
    # end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually neccesary.
    # config.add_search_field('subject') do |field|
    #   field.qt = 'search'
    #   field.solr_parameters = {
    #     'spellcheck.dictionary': 'subject',
    #     qf: '${subject_qf}',
    #     pf: '${subject_pf}'
    #   }
    # end

    # Add search fields to blacklight's built-in advanced search form.
    # Advanced search relies on solr's json query dsl. In order to make a valid json query, we have to include our
    # search parameters in a clause_params hash. The default blacklight processor chain ensures that the presence of
    # clause_params will build a request using the json_solr_path configuration.

    config.add_search_field 'all_fields_advanced', label: I18n.t('advanced.all_fields') do |field|
      field.include_in_advanced_search = true
      field.include_in_simple_select = false
      field.clause_params = { edismax: { qf: QUERY_FIELDS.join(' '), pf: QUERY_FIELDS.join(' ') } }
    end

    QUERY_FIELDS.each do |query_field|
      next if query_field.in? %i[id isxn_search]

      label = I18n.t("advanced.#{query_field}")

      config.add_search_field(query_field, label: label) do |field|
        field.include_in_advanced_search = true
        field.include_in_simple_select = false
        field.clause_params = { edismax: { qf: query_field, pf: query_field } }
      end
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the Solr field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case). Add the sort: option to configure a
    # custom Blacklight url parameter value separate from the Solr sort fields.
    config.add_sort_field 'score desc', label: I18n.t('sort.relevance')
    config.add_sort_field 'creator_sort asc, score desc', label: I18n.t('sort.creator_asc')
    config.add_sort_field 'creator_sort desc, score desc', label: I18n.t('sort.creator_desc')
    config.add_sort_field 'title_sort asc, score desc', label: I18n.t('sort.title_asc')
    config.add_sort_field 'title_sort desc, score desc', label: I18n.t('sort.title_desc')

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Disable autocomplete suggester
    config.autocomplete_enabled = false
  end
  def databases
    # replace string value with PennMarc constant when available
    redirect_to search_catalog_path({ 'f[format_facet][]': 'Database & Article Index' })
  end
end
