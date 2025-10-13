# frozen_string_literal: true

# Wrappers for Solr API calls used to set up and maintain Solr collections for development and test environments
class SolrTools
  class CommandError < StandardError; end

  def self.collection_exists?(collection_name)
    list = connection.get('/solr/admin/collections', action: 'LIST')
    configsets = JSON.parse(list.body)['collections']
    configsets.include? collection_name
  end

  def self.load_configset(name, path)
    outcome = connection.post('/solr/admin/configs') do |req|
      req.params = { action: 'UPLOAD', name: name }
      req.headers['Content-Type'] = 'octect/stream'
      req.body = File.read(path)
    end
    raise CommandError, "Solr command failed with response: #{outcome.body}" unless outcome.success?
  end

  def self.create_collection(collection_name, configset_name)
    response = connection.get('/solr/admin/collections',
                              action: 'CREATE', name: collection_name,
                              numShards: '1', 'collection.configName': configset_name)
    raise CommandError, "Solr command failed with response: #{response.body}" unless response.success?
  end

  # Add llm configuration to solr
  def self.load_model
    model = {
      "class": 'dev.langchain4j.model.openai.OpenAiEmbeddingModel',
      "name": 'openai',
      "params": {
        "baseUrl": 'https://api.openai.com/v1',
        "apiKey": Rails.application.credentials.openai_api_key,
        "modelName": 'text-embedding-3-small',
        "timeout": 60,
        "logRequests": true,
        "logResponses": true,
        "maxRetries": 5
      }
    }.to_json

    response = connection.put('/solr/find-development/schema/text-to-vector-model-store') do |req|
      req.body = model
      req.headers['Content-Type'] = 'application/json'
    end
    raise CommandError, "Solr command failed with response: #{response.body}" unless response.success?
  end

  def self.load_data(collection_name, documents_file_path)
    body = "{ \"add\": [#{File.readlines(documents_file_path).join(',')}] }"
    response = connection.post("/solr/#{collection_name}/update") do |req|
      req.params = { commit: 'true', "update.chain": 'textToVector' }
      req.headers['Content-Type'] = 'application/json'
      req.body = body
    end
    raise CommandError, "Solr command failed with response: #{response.body}" unless response.success?
  end

  def self.clear_collection(collection_name)
    body = "{'delete': {'query': '*:*'}}"
    response = connection.post("/solr/#{collection_name}/update") do |req|
      req.params = { commit: 'true' }
      req.headers['Content-Type'] = 'application/json'
      req.body = body
    end
    raise CommandError, "Solr command failed with response: #{response.body}" unless response.success?
  end

  # Returns name of current collection configured in the Solr URL.
  def self.current_collection_name
    uri = URI.parse(Settings.solr_url)
    uri.path.delete_prefix('/solr/')
  end

  # Check if Solr is up by checking cluster state API
  # @return [Boolean]
  def self.solr_available?
    connection.get('solr/admin/collections', action: 'CLUSTERSTATUS').success?
  rescue StandardError => _e
    false
  end

  def self.connection
    uri = URI.parse(Settings.solr_url) # Parsing out connection details from URL.

    Faraday.new("#{uri.scheme}://#{uri.host}:#{uri.port}") do |faraday|
      faraday.request :authorization, :basic, uri.user, uri.password
      faraday.adapter :net_http
    end
  end
end
