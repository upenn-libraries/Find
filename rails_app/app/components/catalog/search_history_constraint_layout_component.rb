# frozen_string_literal: true

module Catalog
  # Inherits from Blacklight::ConstraintLayoutComponent v8.12.2 to ensure adv search constraints match style of
  # constraints in catalog views
  class SearchHistoryConstraintLayoutComponent < Blacklight::ConstraintLayoutComponent
    def call
      label = tag.span(@label, class: 'filter-name')
      value = tag.span(@value, class: 'filter-value', title: strip_tags(@value))

      constraint = tag.span(class: 'constraint-value btn btn-outline-secondary') do
        safe_join([label, value].compact, ' ')
      end

      tag.span(constraint, class: 'btn-group applied-filter constraint')
    end
  end
end
