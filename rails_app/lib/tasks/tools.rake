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

        config_zip_path = Rails.root.join('solr', latest_configset_file)
        configset_name = "find-configset-#{latest_configset_file.basename.to_s.split('_').last.gsub('.zip', '')}"
        puts "Loading Solr configset from : #{latest_configset_file}"
        SolrTools.load_configset configset_name, config_zip_path
        puts 'Creating Solr collections for development and test'
        SolrTools.create_collection 'find-development', configset_name
        SolrTools.create_collection 'find-test', configset_name
        Rake::Task['tools:index_sample_file'].execute
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
    # Create or find alerts
    Rake::Task['tools:create_alerts'].execute
  end

  desc 'Index record to Solr from JSONL file in storage dir'
  task index_sample_file: :environment do
    latest_solrjson_file = Rails.root.join('solr').glob('solrjson_*.jsonl').max_by { |f| File.mtime(f) }
    raise StandardError, 'Solr JSON file missing' unless latest_solrjson_file

    unless SolrTools.collection_exists?('find-development')
      raise StandardError, '"find-development" collection does not exist'
    end

    puts "Loading latest SolrJSON #{latest_solrjson_file} file from storage dir."
    SolrTools.load_data 'find-development', Rails.root.join('solr', latest_solrjson_file)
    puts 'Records indexed!'
  end

  desc 'Create alerts'
  task create_alerts: :environment do
    puts 'Creating alerts...'
    Alert.find_or_create_by(scope: 'alert') do |alert|
      alert.on = false
      alert.text = '<p>General alert</p>'
    end
    Alert.find_or_create_by(scope: 'find_only_alert') do |alert|
      alert.on = false
      alert.text = '<p>Find only alert</p>'
    end
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
