# frozen_string_literal: true

namespace :tools do
  desc 'Initialize project, including Solr collections and database'
  task start: :environment do
    system('docker-compose up -d')
    sleep 2 # give services some time to start up before proceeding
    if SolrTools.collection_exists? 'find-development'
      puts 'Development collection exists'
    else
      puts 'Setting up basic auth for Solr...'
      system('docker-compose exec solrcloud solr auth enable -credentials catalog:catalog')
      begin
        latest_configset_file = Rails.root.join('solr').glob('configset_*.zip').max_by { |f| File.mtime(f) }
        raise StandardError, 'Configset file missing' unless latest_configset_file

        latest_solrjson_file = Rails.root.join('solr').glob('solrjson_*.jsonl').max_by { |f| File.mtime(f) }
        raise StandardError, 'Solr JSON file missing' unless latest_solrjson_file

        config_zip_path = Rails.root.join('solr', latest_configset_file)
        configset_name = "find-configset-#{latest_configset_file.basename.to_s.split('_').last.gsub('.zip', '')}"
        puts "Loading Solr configset from : #{latest_configset_file}"
        SolrTools.load_configset configset_name, config_zip_path
        puts 'Creating Solr collections for development and test'
        SolrTools.create_collection 'find-development', configset_name
        SolrTools.create_collection 'find-test', configset_name
        puts "Indexing records into Solr from #{latest_solrjson_file}"
        SolrTools.load_data 'find-development', Rails.root.join('solr', latest_solrjson_file)
      rescue StandardError => e
        puts "Problem configuring Solr: #{e.message}"
        puts 'Stopping services'
        system('docker-compose stop')
        next # rake for early return
      end
    end
    begin
      ActiveRecord::Base.connection
    rescue ActiveRecord::NoDatabaseError
      puts 'Creating databases...'
      ActiveRecord::Tasks::DatabaseTasks.create_current
    end
    # Migrate databases
    puts 'Migrating databases...'
    system('RAILS_ENV=development rake db:migrate')
    system('RAILS_ENV=test rake db:migrate')
  end

  desc 'Stop running containers'
  task stop: :environment do
    system('docker-compose stop')
  end

  desc 'Removes containers and volumes'
  task clean: :environment do
    system('docker-compose down --volumes')
  end
end

# Wrappers for Solr API calls used to set up Solr index for development and test environments
# TODO: put this somewhere else
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

  def self.load_data(collection_name, documents_file_path)
    body = "{ \"add\": [#{File.readlines(documents_file_path).join(',')}] }"
    response = connection.post("/solr/#{collection_name}/update") do |req|
      req.params = { commit: 'true' }
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

  def self.connection
    Faraday.new('http://localhost:8983/') do |faraday|
      faraday.request :authorization, :basic, 'catalog', 'catalog'
      faraday.adapter :net_http
    end
  end
end
