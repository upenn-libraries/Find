# frozen_string_literal: true

# The breadcrumb trail, rendered once by the layout.
#
# Every trail opens the same way, so the component supplies both opening crumbs and a page adds only
# what sits below them:
#
#   Penn Libraries / Find / <the page's own crumbs>
#
# The first points at the Penn Libraries site, matching the design system's breadcrumb so people can
# tell where they are across our apps. The second points at this app, and becomes the page you are on
# when nothing is added after it, which is what the home page wants.
class BreadcrumbsComponent < ViewComponent::Base
  renders_many :breadcrumbs, BreadcrumbComponent

  def initialize(**options)
    @options = options

    @options[:class] = Array.wrap(@options[:class])
  end

  def call
    tag.nav('aria-label': t('breadcrumbs.aria'), **@options) do
      tag.ol(class: 'pl-breadcrumb') { safe_join([home_breadcrumb, root_breadcrumb, *breadcrumbs]) }
    end
  end

  private

  # @return [String]
  def home_breadcrumb
    render(BreadcrumbComponent.new(href: t('urls.home'))) { t('breadcrumbs.home') }
  end

  # A link on every page but the home page, where it is where you already are
  # @return [String]
  def root_breadcrumb
    render(BreadcrumbComponent.new(href: (helpers.root_path if breadcrumbs?))) { t('breadcrumbs.root') }
  end
end
