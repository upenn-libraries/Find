# frozen_string_literal: true

# Controller to support a legacy Blacklight API response format to support Leganto integration
# See: https://knowledge.exlibrisgroup.com/Leganto/Product_Documentation/Leganto_Online_Help_(English)/Leganto_Administration_Guide/yy_Appendix_D%3A_Integration_with_Blacklight#Blacklight_Settings
# I think Leganto can only support this API responding to "/catalog.json" based on my reading of the docs.
# Leganto configuration expects:
# - marc field name (marcxml)
# - field_name_type (format)
# Then optionally:
# - field_name_mmsid (mms id)
# - field_name_view_online (record URL)
# Leganto expects the response to have a docs attribute with an array of documents
class LegacyApiController < ActionController::API
  include Blacklight::Controller
  include Blacklight::Searchable

  def index
    @response = search_service.search_results

    render json: {
      docs: @response.documents.filter_map do |doc|
        doc_response_format(doc)
      end
    }
  end

  private

  # Appease Leganto Blacklight integration
  # @param [SolrDocument] document
  # @return [Hash{Symbol->String}]
  def doc_response_format(document)
    { mmsid: document.id,
      marcxml: document.fetch('marcxml_marcxml')
      # format: document.format, # TODO: fix
      # link: document.link # TODO: fix
    }
  end
end
