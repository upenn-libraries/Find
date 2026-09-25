# frozen_string_literal: true

# Collects the trail a page sits on. The layout renders the breadcrumb once, the same way it renders
# the header once, so a page says only where it is:
#
#   <% breadcrumb t('account.breadcrumbs.base'), href: account_path %>
#   <% breadcrumb t('account.fines_and_fees.page_heading') %>
#
# The opening crumbs, Penn Libraries and Find, come from BreadcrumbsComponent, so no page declares
# them. A page that adds nothing gets just those two, which is what the home page wants.
module BreadcrumbsHelper
  # Adds a crumb to the end of the trail. Templates run before the layout, so anything added here,
  # including from a partial, is in place by the time the layout renders.
  # @param label [String] can be markup, such as a clamped record title
  # @param href [String, nil] leave it out for the page you are on
  # @return [Array<Hash>]
  def breadcrumb(label, href: nil)
    page_breadcrumbs << { label: label, href: href }
  end

  # @return [Array<Hash>]
  def page_breadcrumbs
    @page_breadcrumbs ||= []
  end
end
