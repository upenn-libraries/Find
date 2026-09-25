# frozen_string_literal: true

# The breadcrumb trail, rendered once by the layout.
#
# Every trail opens the same way, so the component supplies both fixed crumbs and a page adds only
# what sits below them, through BreadcrumbsHelper#breadcrumb:
#
#   Penn Libraries / Find / <the page's own crumbs>
#
# The first points at the Penn Libraries site, matching the design system's breadcrumb so people can
# tell where they are across our apps. The second points at this app, and becomes the current page
# when a page adds nothing of its own, which is what the home page wants.
class BreadcrumbsComponent < ViewComponent::Base
  # @param crumbs [Array<Hash>] each with a :label and an optional :href; no :href means current page
  def initialize(crumbs: [], **options)
    @crumbs = crumbs
    @options = options

    @options[:class] = Array.wrap(@options[:class])
  end

  def call
    tag.nav('aria-label': t('breadcrumbs.aria'), **@options) do
      tag.ol(class: 'pl-breadcrumb') { safe_join(opening_crumbs + page_crumbs) }
    end
  end

  private

  # @return [Array<String>]
  def opening_crumbs
    [crumb(t('breadcrumbs.home'), href: t('urls.home')),
     crumb(t('breadcrumbs.root'), href: (helpers.root_path if @crumbs.any?))]
  end

  # @return [Array<String>]
  def page_crumbs
    @crumbs.map { |crumb| crumb(crumb[:label], href: crumb[:href]) }
  end

  # @return [String]
  def crumb(label, href:)
    render(BreadcrumbComponent.new(href: href, active: href.nil?)) { label }
  end
end
