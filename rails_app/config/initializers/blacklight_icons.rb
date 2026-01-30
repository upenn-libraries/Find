# frozen_string_literal: true

# Override Blacklight's default remove (x) icon with a simpler design
Rails.application.config.after_initialize do
  Blacklight::Icons::RemoveComponent.svg = <<~SVG
    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none">
      <path d="M18 6L6 18M6 6L18 18" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>
  SVG
end
