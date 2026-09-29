# frozen_string_literal: true

module Catalog
  # Local component copied from Blacklight v9.2.1 to allow us to use a custom layout template.
  # Adds icon, tooltip and aria markup, overriding the #call method on the component.
  class StartOverButtonComponent < Blacklight::StartOverButtonComponent
    def call
      link_to start_over_path, class: 'catalog_startOverLink btn btn-light',
                               aria: { label: start_over_label },
                               data: { controller: 'tooltip', bs_title: start_over_label } do
        render 'shared/svgs/start_over'
      end
    end

    private

    # @return [String]
    def start_over_label
      t('blacklight.search.start_over')
    end
  end
end
