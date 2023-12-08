# frozen_string_literal: true

# Package query field config for awareness and easy tuning. Typically this consists of
# `qf` Query Fields - https://solr.apache.org/guide/solr/latest/query-guide/dismax-query-parser.html#qf-query-fields-parameter
# `pf` Phrase Fields - https://solr.apache.org/guide/solr/latest/query-guide/dismax-query-parser.html#ps-phrase-slop-parameter
# `ps` Phrase Slop - https://solr.apache.org/guide/solr/latest/query-guide/dismax-query-parser.html#ps-phrase-slop-parameter
# The values are used with search_field_config in Blacklight configuration as `solr_parameters`
module SearchFieldConfig
  # For guidance, Franklin field configuration and boosts can be seen here: https://gitlab.library.upenn.edu/franklin/franklin-solr-config/-/blob/pod/conf/solrconfig.xml#L795
  # TODO: lots of work to do here in the name of relevance
  # TODO: move this to the solr config when it become more static
  ALL_FIELDS = {
    qf: 'creator_search^3
         title_search^2.5
         title_aux_search^1.5
         subject_search^1
         isxn_search^1
         id^1',
    pf: 'creator_search^3
         title_search^2.5
         title_aux_search^1.5
         subject_search^1
         isxn_search^1
         id^1',
    ps: '3'
  }.freeze

  TITLE = {
    qf: 'title_search^3
         title_aux_search^0.5',
    pf: 'title_search^3
         title_aux_search^0.5'
  }.freeze

  JOURNAL_TITLE = {
    qf: 'journal_title_search^3
         journal_title_aux_search^0.5',
    pf: 'journal_title_search^3
         journal_title_aux_search^0.5'
  }.freeze

  # TODO: do we need a creator aux field? franklin has author_creator_2_search
  CREATOR = {
    qf: 'creator_search^3',
    pf: 'creator_search^3'
  }.freeze

  SUBJECT = {
    qf: 'subject_search^1.5',
    pf: 'subject_search^1'
  }.freeze

  GENRE = {
    qf: 'genre_search^1.5',
    pf: 'genre_search^1'
  }.freeze
end
