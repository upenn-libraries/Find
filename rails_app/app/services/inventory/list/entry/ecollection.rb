# frozen_string_literal: true

module Inventory
  class List
    module Entry
      # Holding class for inventory derived from an Alma E-Collection record
      class Ecollection < Base
        alias collection_id id

        # @return [String, nil]
        def id
          data[:id]
        end

        # @return [String]
        def description
          data[:public_name_override].presence || data[:public_name].presence ||
            I18n.t('inventory.fallback_electronic_access_button_label')
        end

        # @return [String]
        def status
          Constants::ELEC_AVAILABLE
        end

        # @return [String]
        def human_readable_status
          I18n.t('alma.availability.electronic.available.label')
        end

        # @return [nil]
        def human_readable_location
          nil
        end

        # @return [nil]
        def policy
          nil
        end

        # @return [nil]
        def format
          nil
        end

        # @return [nil]
        def coverage_statement
          nil
        end

        # @return [String, nil]
        # rubocop:disable Rails/OutputSafety
        def public_note
          sanitize(data[:public_note], tags: ALLOWED_TAGS).html_safe
        end
        # rubocop:enable Rails/OutputSafety

        # @return [String, nil]
        def href
          data[:url_override].presence || data[:url]
        end

        # @return [Boolean]
        def electronic?
          true
        end

        # @return [Boolean]
        def ecollection?
          true
        end

        # Only show well-coded e-collection records
        # @return [Boolean]
        def displayable?
          description.present? && href.present?
        end
      end
    end
  end
end
