# frozen_string_literal: true

ActiveSupport::Reloader.to_prepare do
  # TODO: this is throwing Uncaught exception: uninitialized constant Blacklight::Rendering
  # Blacklight::Rendering::Pipeline.operations = [Blacklight::Rendering::HelperMethod,
  #                                               Blacklight::Rendering::LinkToFacet,
  #                                               Blacklight::Rendering::Microdata,
  #                                               Find::LinkToProcessor,
  #                                               Find::JoinProcessor]
end
