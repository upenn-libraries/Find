# frozen_string_literal: true

ActiveSupport::Reloader.to_prepare do
  # TODO: this is throwing Uncaught exception: uninitialized constant Blacklight::Rendering
  #       could it be related to the addition of zeitwerk in BL 8.4?
  #       see: https://github.com/projectblacklight/blacklight/pull/3279/files
  Blacklight::Rendering::Pipeline.operations = [Blacklight::Rendering::HelperMethod,
                                                Blacklight::Rendering::LinkToFacet,
                                                Blacklight::Rendering::Microdata,
                                                Find::LinkToProcessor,
                                                Find::JoinProcessor]
end
