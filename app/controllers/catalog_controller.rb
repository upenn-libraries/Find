# frozen_string_literal: true

# Blacklight controller that handles searches and document requests
class CatalogController < ApplicationController
  include Blacklight::Catalog

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
    config.default_solr_params = { qt: 'search' }

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
    config.header_component = Find::HeaderComponent
    config.index.search_bar_component = Find::SearchBarComponent

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

    # TODO: Our override of the TopNavbarComponent means render_nav_actions is never called in any view. We need a new
    #       place to render these "nav actions", or commit to doing away with them.
    # config.add_nav_action(:bookmark, partial: 'blacklight/nav/bookmark', if: :render_bookmarks_control?)
    # config.add_nav_action(:search_history, partial: 'blacklight/nav/search_history')

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

    # Configure database facets

    # lambda to control database facets display
    database_selected = lambda { |controller, _config, _field|
      controller.params.dig(:f, :format_facet)&.include?(PennMARC::Database::DATABASES_FACET_VALUE)
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
    config.add_facet_field :classification_facet, label: I18n.t('facets.classification'), limit: 5

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field :creator_ss, label: I18n.t('results.creator')
    config.add_index_field :edition_ss, label: I18n.t('results.edition')
    config.add_index_field :conference_ss, label: I18n.t('results.conference')
    config.add_index_field :series_ss, label: I18n.t('results.series')
    config.add_index_field :publication_ss, label: I18n.t('results.publication')
    config.add_index_field :production_ss, label: I18n.t('results.production')
    config.add_index_field :distribution_ss, label: I18n.t('results.distribution')
    config.add_index_field :manufacture_ss, label: I18n.t('results.manufacture')
    config.add_index_field :contained_within_ss, label: I18n.t('results.contained_within')
    config.add_index_field :format_ss, label: I18n.t('results.format'), separator: ', '
    config.add_index_field :full_text_links_ss, label: I18n.t('results.full_text')

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

    config.add_search_field 'all_fields', label: I18n.t('search.all_fields') do |field|
      field.include_in_advanced_search = false
      field.solr_parameters = SearchFieldConfig::ALL_FIELDS
    end

    # Add search fields to Blacklight's built-in advanced search form.
    # Advanced search relies on solr's json query dsl. In order to make a valid json query, we have to include our
    # search parameters in a clause_params hash. The default blacklight processor chain ensures that the presence of
    # clause_params will build a request using the json_solr_path configuration.

    config.add_search_field 'all_fields_advanced', label: I18n.t('advanced.all_fields') do |field|
      field.include_in_advanced_search = true
      field.include_in_simple_select = false
      field.clause_params = { edismax: SearchFieldConfig::ALL_FIELDS }
    end

    config.add_search_field('creator_search', label: I18n.t('advanced.creator_search')) do |field|
      field.include_in_advanced_search = true
      field.include_in_simple_select = false
      field.clause_params = { edismax: SearchFieldConfig::CREATOR }
    end

    config.add_search_field('title_search', label: I18n.t('advanced.title_search')) do |field|
      field.include_in_advanced_search = true
      field.include_in_simple_select = false
      field.clause_params = { edismax: SearchFieldConfig::TITLE }
    end

    config.add_search_field('journal_title_search', label: I18n.t('advanced.journal_title_search')) do |field|
      field.include_in_advanced_search = true
      field.include_in_simple_select = false
      field.clause_params = { edismax: SearchFieldConfig::JOURNAL_TITLE }
    end

    config.add_search_field('subject_search', label: I18n.t('advanced.subject_search')) do |field|
      field.include_in_advanced_search = true
      field.include_in_simple_select = false
      field.clause_params = { edismax: SearchFieldConfig::SUBJECT }
    end

    config.add_search_field('genre_search', label: I18n.t('advanced.genre_search')) do |field|
      field.include_in_advanced_search = true
      field.include_in_simple_select = false
      field.clause_params = { edismax: SearchFieldConfig::GENRE }
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
    redirect_to search_catalog_path({ 'f[format_facet][]': PennMARC::Database::DATABASES_FACET_VALUE })
  end
end
