# frozen_string_literal: true

namespace :tools do
  desc 'Initialize project, including Solr collections and database'
  task start: :environment do
    system('docker compose up -d')
    puts 'Waiting for Solr to be available...'
    sleep 1 until SolrTools.solr_available?
    begin
      if Settings.solr_url.include?('catalog-manager')
        puts 'Our sensors detect that you are using a solr_url setting for a deployed Solr instance.'
        puts 'Skipping Solr service setup (though a Solr Docker container will run)'
      elsif SolrTools.collection_exists? 'find-development'
        puts 'Development collection exists'
      else
        puts 'Setting up basic auth for Solr...'
        system('docker compose exec solrcloud solr auth enable -credentials catalog:catalog')
        latest_configset_file = Rails.root.join('solr').glob('configset_*.zip').max_by { |f| File.mtime(f) }
        raise StandardError, 'Configset file missing' unless latest_configset_file

        configset_name = "find-configset-#{latest_configset_file.basename.to_s.split('_').last.gsub('.zip', '')}"
        puts "Loading Solr configset from : #{latest_configset_file}"
        SolrTools.load_configset configset_name, latest_configset_file
        puts 'Creating Solr collections for development and test'
        SolrTools.create_collection 'find-development', configset_name
        SolrTools.create_collection 'find-test', configset_name
        Rake::Task['tools:index_sample_file'].execute
      end
    rescue StandardError => e
      puts "Problem configuring Solr: #{e.message}"
      puts 'Stopping services'
      system('docker compose stop')
      next # rake for early return
    end
    puts 'Creating databases...'
    ActiveRecord::Tasks::DatabaseTasks.create_current
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
    system('docker compose stop')
  end

  desc 'Removes containers and volumes'
  task clean: :environment do
    system('docker compose down --volumes')
  end
end
