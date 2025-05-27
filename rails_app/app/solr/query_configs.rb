# frozen_string_literal: true

# Hold some Solr configuration params, perhaps temporarily while we iterate on query-time configuration to improve
# relevance
class QueryConfigs
  class << self
    def basic_query_params
      {
        qf: filtered_config(:qf, remove: %w[unstem anchored]),
        pf: filtered_config(:pf, remove: %w[unstem anchored]),
        pf2: filtered_config(:pf2, remove: %w[unstem anchored]),
        pf3: filtered_config(:pf3, remove: %w[unstem anchored])
      }
    end

    def no_anchored_query_params
      {
        qf: filtered_config(:qf, remove: 'anchored'),
        pf: filtered_config(:pf, remove: 'anchored'),
        pf2: filtered_config(:pf2, remove: 'anchored'),
        pf3: filtered_config(:pf3, remove: 'anchored')
      }
    end

    def no_unstem_query_params
      {
        qf: filtered_config(:qf, remove: 'unstem'),
        pf: filtered_config(:pf, remove: 'unstem'),
        pf2: filtered_config(:pf2, remove: 'unstem'),
        pf3: filtered_config(:pf3, remove: 'unstem')
      }
    end

    private

    def filtered_config(config, remove: [])
      remove = Array.wrap(remove)
      fields = send("keyword_config_fields_#{config}")
      remove.each { |r| fields.reject! { |f| f.include?(r) } }
      fields.join(' ')
    end

    def keyword_config_fields_qf
      %w[
        mmsid^100000
        doi_ss^10000
        oclc_id_ss^10000
        isxn_search^8000
        call_number_search^5000
        title_anchored_search^1000 title_unstem_search^300 title_search^250
        title_aux_anchored_search^700 title_aux_unstem_search^250 title_aux_search^200
        journal_title_anchored_search^1000 journal_title_unstem_search^300 journal_title_search^200
        journal_title_aux_unstem_search^250 journal_title_search^150
        series_anchored_search^700 series_unstem_search^300 series_search^150
        creator_unstem_search^700 creator_aux_unstem_search^500
        conference_unstem_search^500 conference_search^300
        subject_unstem_search^750 subject_search^600
        genre_unstem_search^650 genre_search^500
        marcxml_marcxml
      ]
    end

    def keyword_config_fields_pf
      %w[
        title_anchored_search^12000 title_unstem_search^10000 title_search^5000
        title_aux_anchored_search^1200 title_aux_unstem_search^1000 title_aux_search^200
        journal_title_anchored_search^1500 journal_title_unstem_search^1000 journal_title_search^200
        journal_title_aux_anchored_search^1100 journal_title_aux_unstem_search^700 journal_title_search^150
        series_anchored_search^1800 series_unstem_search^1500 series_search^200
        creator_unstem_search^2000
        creator_aux_unstem_search^500
        conference_unstem_search^500 conference_search^75
        subject_unstem_search^2000 subject_search^150
        genre_unstem_search^1000 genre_search^150
        marcxml_marcxml^100
      ]
    end

    def keyword_config_fields_pf2
      %w[
        title_anchored_search^50000 title_unstem_search^30000 title_search^10000
        title_aux_anchored_search^4000 title_aux_unstem_search^1500 title_aux_search^200
        journal_title_aux_anchored_search^40000 journal_title_unstem_search^25000 journal_title_search^200
        journal_title_aux_anchored_search^5000 journal_title_aux_unstem_search^2500 journal_title_aux_search^150
        series_anchored_search^5000 series_unstem_search^3000 series_search^400
        creator_unstem_search^4500
        creator_aux_unstem_search^2000
      ]
    end

    def keyword_config_fields_pf3
      %w[
        title_anchored_search^80000 title_unstem_search^60000 title_search^15000
        title_aux_anchored_search^6000 title_aux_unstem_search^2500 title_aux_search^200
        journal_title_anchored_search^80000 journal_title_unstem_search^50000 journal_title_search^200
        journal_title_aux_anchored_search^6000 journal_title_aux_unstem_search^2500 journal_title_aux_search^150
        series_anchored_search^15000 series_unstem_search^10000 series_search^1000
        creator_unstem_search^7000
        creator_aux_unstem_search^4000
      ]
    end
  end
end