# frozen_string_literal: true

# Renders a callout component with optional header
class CalloutComponent < ViewComponent::Base
  # Renders an optional heading inside a callout
  #
  # @param heading [String] the heading text
  # @param tag [Symbol] the heading tag, defaults to :h2
  # @param options [Hash] additional options for the component
  # @option options [String] :h_class bootstrap heading class for heading display, regardless of tag, defaults to 'h4'
  # @option options [String] :m_classes bootstrap margin class(es) for heading, defaults to 'mb-3'
  # @option options [Array<String>, String] :class class(es) to apply to the heading, overriding existing if multiple apply
  renders_one :heading, lambda { |heading, tag: :h2, **options|
    h_class = options[:h_class] || 'h4'
    m_classes = Array.wrap(options[:m_class] || 'mb-3')
    classes = [h_class, m_classes, options[:class]].compact

    content_tag(tag, heading, class: classes)
  }


  # Initializes a new callout component
  #
  # @param variant [Symbol] the variant of the callout, matching a bootstrap border class modifier
  # @param options [Hash] additional options for the component
  # @option options [String] :m_class bootstrap margin class(es), defaults to 'my-3'
  # @option options [String] :p_class bootstrap padding class(es), defaults to 'p-3'
  # @option options [String] :container_class class(es) to apply to the component's container, in addition to or overriding default
  # @option options [String] :content_class class(es) to apply to the component's content, in addition to or overriding default
  def initialize(variant: :primary, **options)
    @variant = variant
    @options = options
  end

  # Returns classes to apply to the callout's container
  def container_classes
    default_classes = %w[card border-start-0]
    m_classes = Array.wrap(@options[:m_class] || 'my-3')
    added_classes = Array.wrap(@options[:container_class])

    [default_classes, m_classes, added_classes].compact.join(' ')
  end

  # Returns classes to apply to the callout's content
  def content_classes
    default_classes = %w[rounded border-start border-4]
    variant_class = "border-#{@variant}"
    p_classes = Array.wrap(@options[:p_class] || 'p-3')
    added_classes = Array.wrap(@options[:content_class])

    [default_classes, variant_class, p_classes, added_classes].compact.join(' ')
  end
end
