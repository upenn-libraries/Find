# frozen_string_literal: true

# Blacklight controller that handles searches and document requests
class CatalogController < ApplicationController
  include Blacklight::Catalog

  before_action :load_document, only: %i[staff_view]

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
    config.index.constraints_component = Find::ConstraintsComponent
    config.index.facet_group_component = Find::FacetGroupComponent
    config.index.document_component = Find::ResultsDocumentComponent
    config.show.document_component = Find::ShowDocumentComponent
    config.show.show_tools_component = Find::ShowToolsComponent

    # Configure local components for search session components that make the show page toolbar possible
    config.track_search_session.item_pagination_component = Find::ServerItemPaginationComponent
    config.track_search_session.applied_params_component = Find::ServerAppliedParamsComponent

    config.add_results_document_tool(:bookmark, component: Blacklight::Document::BookmarkComponent,
                                                if: :render_bookmarks_control?)

    config.add_results_collection_tool(:sort_widget)
    config.add_results_collection_tool(:per_page_widget)
    config.add_results_collection_tool(:view_type_group)

    config.add_show_tools_partial(:bookmark, component: Find::BookmarkComponent,
                                             if: :render_bookmarks_control?)
    config.add_show_tools_partial(:email, if: :user_signed_in?, callback: :email_action,
                                          validator: :validate_email_params)
    config.add_show_tools_partial(:login_for_email, unless: :user_signed_in?, modal: false, path: 'login_path')
    config.add_show_tools_partial(:citation)
    config.add_show_tools_partial(:staff_view, modal: false, unless: :bookmarks?)

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
                                                  show: database_selected,
                                                  limit: -1, sort: 'index' do |field|
      field.include_in_advanced_search = false
    end
    config.add_facet_field :db_type_facet, label: I18n.t('facets.databases.type'),
                                           show: database_selected,
                                           limit: -1, sort: 'index' do |field|
      field.include_in_advanced_search = false
    end

    # Configure general facets
    config.add_facet_field :access_facet, label: I18n.t('facets.access')
    config.add_facet_field :format_facet, label: I18n.t('facets.format'), limit: true
    config.add_facet_field :creator_facet, label: I18n.t('facets.creator'), limit: true do |field|
      field.include_in_advanced_search = false
    end
    config.add_facet_field :subject_facet, label: I18n.t('facets.subject'), limit: true do |field|
      field.include_in_advanced_search = false
    end
    config.add_facet_field :language_facet, label: I18n.t('facets.language'), limit: true
    config.add_facet_field :library_facet, label: I18n.t('facets.library'), limit: true
    config.add_facet_field :location_facet, label: I18n.t('facets.location'), limit: true
    config.add_facet_field :genre_facet, label: I18n.t('facets.genre'), limit: true do |field|
      field.include_in_advanced_search = false
    end
    config.add_facet_field :classification_facet, label: I18n.t('facets.classification'), limit: 5
    config.add_facet_field :recently_published_facet, label: I18n.t('facets.recently_published.label'), solr_params:
      { 'facet.mincount': 1 }, query: { last_5_years: { label: I18n.t('facets.recently_published.5_years'),
                                                        fq: 'publication_date_sort:[NOW/YEAR-4YEARS TO *]' },
                                        last_10_years: { label: I18n.t('facets.recently_published.10_years'),
                                                         fq: 'publication_date_sort:[NOW/YEAR-9YEARS TO *]' },
                                        last_15_years: { label: I18n.t('facets.recently_published.15_years'),
                                                         fq: 'publication_date_sort:[NOW/YEAR-14YEARS TO *]' } }
    config.add_facet_field :recently_added_facet, label: I18n.t('facets.recently_added.label'), solr_params:
      { 'facet.mincount': 1 }, query: {
        within_15_days: { label: I18n.t('facets.recently_added.15_days'), fq: 'added_date_sort:[NOW/DAY-15DAYS TO *]' },
        within_30_days: { label: I18n.t('facets.recently_added.30_days'), fq: 'added_date_sort:[NOW/DAY-30DAYS TO *]' },
        within_60_days: { label: I18n.t('facets.recently_added.60_days'), fq: 'added_date_sort:[NOW/DAY-60DAYS TO *]' },
        within_90_days: { label: I18n.t('facets.recently_added.90_days'), fq: 'added_date_sort:[NOW/DAY-90DAYS TO *]' }
      }

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field :score, label: I18n.t('results.score'), if: :show_score?, helper_method: :as_badge
    config.add_index_field :format_facet, label: I18n.t('results.format')
    config.add_index_field :creator_ss, label: I18n.t('results.creator')
    config.add_index_field :edition_ss, label: I18n.t('results.edition')
    config.add_index_field :conference_ss, label: I18n.t('results.conference')
    config.add_index_field :series_ss, label: I18n.t('results.series')
    config.add_index_field :publication_ss, label: I18n.t('results.publication')
    config.add_index_field :production_ss, label: I18n.t('results.production')
    config.add_index_field :distribution_ss, label: I18n.t('results.distribution')
    config.add_index_field :manufacture_ss, label: I18n.t('results.manufacture')
    config.add_index_field :contained_within_ss, label: I18n.t('results.contained_within')

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field :format_facet, label: I18n.t('results.format')
    config.add_show_field :creator_show, label: I18n.t('show.creator.main'), accessor: :marc,
                                         component: Find::FacetLinkComponent, facet_target: :creator_facet,
                                         facet_map: :creator_show_facet_map
    config.add_show_field :format_show, label: I18n.t('show.format.main'), accessor: :marc
    config.add_show_field :edition_show, label: I18n.t('show.edition.main'), accessor: :marc
    config.add_show_field :creator_conference_detail_show, label: I18n.t('show.creator.conference_detail'),
                                                           accessor: :marc, component: Find::FacetLinkComponent,
                                                           facet_target: :creator_facet,
                                                           facet_map: :creator_conference_detail_show_facet_map
    config.add_show_field :series_show, label: I18n.t('show.series.main'), accessor: :marc
    config.add_show_field :production_show, label: I18n.t('show.production.main'), accessor: :marc
    config.add_show_field :production_distribution_show, label: I18n.t('show.production.distribution'), accessor: :marc
    config.add_show_field :production_manufacture_show, label: I18n.t('show.production.manufacture'), accessor: :marc
    config.add_show_field :relation_contained_in_show, label: I18n.t('show.relation.contained_in'), accessor: :marc
    config.add_show_field :title_standardized_show, label: I18n.t('show.title.standardized'), accessor: :marc
    config.add_show_field :title_other_show, label: I18n.t('show.title.other'), accessor: :marc
    config.add_show_field :format_cartographic_show, label: I18n.t('show.format.cartographic'), accessor: :marc
    config.add_show_field :identifier_fingerprint_show, label: I18n.t('show.identifier.fingerprint'), accessor: :marc
    config.add_show_field :note_arrangement_show, label: I18n.t('show.notes.arrangement'), accessor: :marc
    config.add_show_field :title_former_show, label: I18n.t('show.title.former'), accessor: :marc
    config.add_show_field :series_get_continues_show, label: I18n.t('show.series.continues'), accessor: :marc
    config.add_show_field :series_get_continued_by_show, label: I18n.t('show.series.continued_by'), accessor: :marc
    config.add_show_field :subject_show, label: I18n.t('show.subject.all'), accessor: :marc,
                                         component: Find::FacetLinkComponent, facet_target: :subject_facet
    config.add_show_field :subject_medical_show, label: I18n.t('show.subject.medical'), accessor: :marc,
                                                 component: Find::FacetLinkComponent, facet_target: :subject_facet
    config.add_show_field :subject_local_show, label: I18n.t('show.subject.local'), accessor: :marc,
                                               component: Find::FacetLinkComponent, facet_target: :subject_facet
    config.add_show_field :genre_show, label: I18n.t('show.genre'), accessor: :marc
    config.add_show_field :production_publication_show, label: I18n.t('show.production.place_of_publication'),
                                                        accessor: :marc
    config.add_show_field :language_show, label: I18n.t('show.language.main'), accessor: :marc
    config.add_show_field :note_system_details_show, label: I18n.t('show.notes.system_details'), accessor: :marc
    config.add_show_field :note_biography_show, label: I18n.t('show.notes.biography'), accessor: :marc
    config.add_show_field :note_summary_show, label: I18n.t('show.notes.summary'), accessor: :marc
    config.add_show_field :note_contents_values, label: I18n.t('show.notes.contents'), accessor: :marc
    config.add_show_field :note_participant_show, label: I18n.t('show.notes.participant'), accessor: :marc
    config.add_show_field :note_credits_show, label: I18n.t('show.notes.credits'), accessor: :marc
    config.add_show_field :note_notes_show, label: I18n.t('show.notes.main'), accessor: :marc
    config.add_show_field :note_local_notes_show, label: I18n.t('show.notes.local_notes'), accessor: :marc
    config.add_show_field :note_finding_aid_show, label: I18n.t('show.notes.finding_aid'), accessor: :marc
    config.add_show_field :note_provenance_show, label: I18n.t('show.notes.provenance'), accessor: :marc
    config.add_show_field :relation_chronology_show, label: I18n.t('show.relation.chronology'), accessor: :marc
    config.add_show_field :relation_related_collections_show, label: I18n.t('show.relation.related_collections'),
                                                              accessor: :marc
    config.add_show_field :citation_cited_in_show, label: I18n.t('show.citation.cited_in'), accessor: :marc
    config.add_show_field :relation_publications_about_show, label: I18n.t('show.relation.publications_about'),
                                                             accessor: :marc
    config.add_show_field :citation_cite_as_show, label: I18n.t('show.citation.cited_as'), accessor: :marc
    config.add_show_field :creator_contributor_show, label: I18n.t('show.creator.contributor'), accessor: :marc,
                                                     component: Find::FacetLinkComponent, facet_target: :creator_facet
    config.add_show_field :relation_related_work_show, label: I18n.t('show.relation.related_work'), accessor: :marc
    config.add_show_field :relation_contains_show, label: I18n.t('show.relation.contains'), accessor: :marc
    config.add_show_field :edition_other_show, label: I18n.t('show.edition.other'), accessor: :marc
    config.add_show_field :relation_constituent_unit_show, label: I18n.t('show.relation.constituent_unit'),
                                                           accessor: :marc
    config.add_show_field :relation_has_supplement_show, label: I18n.t('show.relation.has_supplement'), accessor: :marc
    config.add_show_field :format_other_show, label: I18n.t('show.format.other'), accessor: :marc
    config.add_show_field :identifier_isbn_show, label: I18n.t('show.identifier.isbn'), accessor: :marc
    config.add_show_field :identifier_issn_show, label: I18n.t('show.identifier.issn'), accessor: :marc
    config.add_show_field :identifier_oclc_id_show, label: I18n.t('show.identifier.oclc_id'), accessor: :marc
    config.add_show_field :identifier_publisher_number_show, label: I18n.t('show.identifier.publisher_number'),
                                                             accessor: :marc
    config.add_show_field :note_access_restriction_show, label: I18n.t('show.notes.access_restriction'), accessor: :marc
    # TODO: populate this field
    # config.add_show_field :bound_with_show, label: I18n.t('show.bound_with'), accessor: :marc
    config.add_show_field :link_web_links, label: I18n.t('show.web_links.main'), accessor: :marc

    config.add_search_field 'all_fields', label: I18n.t('search.all_fields') do |field|
      field.include_in_advanced_search = false
    end

    # Add search fields to Blacklight's built-in advanced search form.
    # Advanced search relies on solr's json query dsl. In order to make a valid json query, we have to include our
    # search parameters in a clause_params hash. The default blacklight processor chain ensures that the presence of
    # clause_params will build a request using the json_solr_path configuration.
    # For ranged search fields, pass the following keyword arguments to add_search_field method call
    # - "range: true"
    # - optionally, pass "pattern" arg with an html based regex to attach to the range inputs for
    #   some client-side validation

    config.add_search_field 'all_fields_advanced', label: I18n.t('advanced.all_fields') do |field|
      field.include_in_advanced_search = true
      field.include_in_simple_select = false
      field.clause_params = { edismax: { qf: '${qf}', pf: '${pf}' } }
    end

    config.add_search_field('creator_search', label: I18n.t('advanced.creator_search')) do |field|
      field.include_in_advanced_search = true
      field.include_in_simple_select = false
      field.clause_params = { edismax: { qf: '${creator_qf}', pf: '${creator_pf}' } }
    end

    config.add_search_field('title_search', label: I18n.t('advanced.title_search')) do |field|
      field.include_in_advanced_search = true
      field.include_in_simple_select = false
      field.clause_params = { edismax: { qf: '${title_qf}', pf: '${title_pf}' } }
    end

    config.add_search_field('journal_title_search', label: I18n.t('advanced.journal_title_search')) do |field|
      field.include_in_advanced_search = true
      field.include_in_simple_select = false
      field.clause_params = { edismax: { qf: '${journal_title_qf}', pf: '${journal_title_pf}' } }
    end

    config.add_search_field('subject_search', label: I18n.t('advanced.subject_search')) do |field|
      field.include_in_advanced_search = true
      field.include_in_simple_select = false
      field.clause_params = { edismax: { qf: '${subject_qf}', pf: '${subject_pf}' } }
    end

    config.add_search_field('genre_search', label: I18n.t('advanced.genre_search')) do |field|
      field.include_in_advanced_search = true
      field.include_in_simple_select = false
      field.clause_params = { edismax: { qf: '${genre_qf}', pf: '${genre_pf}' } }
    end

    config.add_search_field('language_search', label: I18n.t('advanced.language_search')) do |field|
      field.include_in_advanced_search = true
      field.include_in_simple_select = false
      field.clause_params = { edismax: { qf: '${language_qf}', pf: '${language_pf}' } }
    end

    config.add_search_field('isxn_search', label: I18n.t('advanced.isxn_search')) do |field|
      field.include_in_advanced_search = true
      field.include_in_simple_select = false
      field.clause_params = { edismax: { qf: '${isxn_qf}', pf: '${isxn_pf}' } }
    end

    config.add_search_field('series_search', label: I18n.t('advanced.series_search')) do |field|
      field.include_in_advanced_search = true
      field.include_in_simple_select = false
      field.clause_params = { edismax: { qf: '${series_qf}', pf: '${series_pf}' } }
    end

    config.add_search_field('publisher_search', label: I18n.t('advanced.publisher_search')) do |field|
      field.include_in_advanced_search = true
      field.include_in_simple_select = false
      field.clause_params = { edismax: { qf: '${publisher_qf}', pf: '${publisher_pf}' } }
    end

    config.add_search_field('place_of_publication_search',
                            label: I18n.t('advanced.place_of_publication_search')) do |field|
      field.include_in_advanced_search = true
      field.include_in_simple_select = false
      field.clause_params = { edismax: { qf: '${place_of_publication_qf}',
                                         pf: '${place_of_publication_pf}' } }
    end

    config.add_search_field('conference_search', label: I18n.t('advanced.conference_search')) do |field|
      field.include_in_advanced_search = true
      field.include_in_simple_select = false
      field.clause_params = { edismax: { qf: '${conference_qf}', pf: '${conference_pf}' } }
    end

    config.add_search_field('corporate_author_search', label: I18n.t('advanced.corporate_author_search')) do |field|
      field.include_in_advanced_search = true
      field.include_in_simple_select = false
      field.clause_params = { edismax: { qf: '${corporate_author_qf}', pf: '${corporate_author_pf}' } }
    end

    config.add_search_field('identifier_publisher_number_search',
                            label: I18n.t('advanced.identifier_publisher_number_search')) do |field|
      field.include_in_advanced_search = true
      field.include_in_simple_select = false
      field.clause_params = { edismax: { qf: '${publisher_number_qf}',
                                         pf: '${publisher_number_pf}' } }
    end

    config.add_search_field('contents_note_search', label: I18n.t('advanced.contents_note_search')) do |field|
      field.include_in_advanced_search = true
      field.include_in_simple_select = false
      field.clause_params = { edismax: { qf: '${contents_note_qf}', pf: '${contents_note_pf}' } }
    end

    config.add_search_field('publication_date_s', label: I18n.t('advanced.publication_date_search'),
                                                  range: true, pattern: '^\\d{4}$') do |field|
      field.include_in_advanced_search = true
      field.include_in_simple_select = false
      field.clause_params = { edismax: { qf: '${publication_date_qf}', pf: '${publication_date_pf}' } }
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
    config.add_sort_field 'publication_date_sort asc, title_sort asc', label: I18n.t('sort.publication_date_asc')
    config.add_sort_field 'publication_date_sort desc, title_sort asc', label: I18n.t('sort.publication_date_desc')
    config.add_sort_field 'added_date_sort asc, title_sort asc', label: I18n.t('sort.added_date_asc')
    config.add_sort_field 'added_date_sort desc, title_sort asc', label: I18n.t('sort.added_date_desc')

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Disable autocomplete suggester
    config.autocomplete_enabled = false
  end

  def databases
    redirect_to search_catalog_path({ 'f[format_facet][]': PennMARC::Database::DATABASES_FACET_VALUE })
  end

  def staff_view; end

  private

  # @return [SolrDocument]
  def load_document
    @document = search_service.fetch(params[:id])
  end

  # @return [Boolean]
  def bookmarks?
    controller_name == 'bookmarks'
  end

  # @return [Boolean]
  def show_score?
    !Rails.env.production? || params[:score].present?
  end
end
