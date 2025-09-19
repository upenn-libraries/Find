# Find - A Penn Libraries Catalog

This application is the front end for the Penn Libraries catalog. It uses 
[Blacklight](https://github.com/projectblacklight/blacklight) to facilitate searching and display of records from a Solr
index. Records are harvested from our ILS (Alma) by the 
[`catalog-indexing`](https://gitlab.library.upenn.edu/dld/catalog/catalog-indexing) app, and parsing of MARC is handled 
by the [`pennmarc`](https://gitlab.library.upenn.edu/dld/catalog/pennmarc) gem 
([docs](https://rubygems.org/gems/pennmarc)).

High-level information about this repo and the available working environments can be found at the [top-level README](README.md).

1. [Local Development Environment](#local-development-environment)
   1. [Requirements](#requirements)
   2. [Starting Services](#starting-app-services)
   3. [Loading Data](#loading-data)
   4. [Developing](#developing)
   5. [Updating Blacklight](#updating-blacklight)
2. [Contributing](#contributing)
   1. [Running the Test Suite](#running-the-test-suite)
   2. [Rubocop](#rubocop)

## Local Development Environment

### Requirements

Your development machine will need the following:

#### Ruby

I suggest installing Ruby via [`rbenv`](https://github.com/rbenv/rbenv) or [`asdf`](https://asdf-vm.com/). There is
plenty of guidance available on the open web about installing and using these tools. The `.ruby-version` and
`.tool-versions` files in this repo explicitly define the version of Ruby to be installed.

> __Important Note:__ The available Vagrant environment relies on a Bundler configuration that houses the installed gems in the `vendor/bundle` directory.
> If you want to use local services, and a local Ruby interpreter (via `rbenv`, `asdf` or somesuch), you'll need to instruct bundler to ignore this configuration when running commands with `bundle` (including `bundle exec`).
>
> To ignore the vagrant-specific Bundler config in a terminal session, run `export BUNDLE_IGNORE_CONFIG=true`. Alternatively, you cna prepend the environment variable with each command; e.g. `BUNDLE_IGNORE_CONFIG=true bundle exec rails c`.

#### Docker Compose

[Docker compose](https://docs.docker.com/compose/install/) is required to run the application services. For 🌈 linux 
users 🌈 this is free and straightforward. [Install docker engine](https://docs.docker.com/engine/install/) and then
[add the compose plugin](https://docs.docker.com/compose/install/linux/#install-the-plugin-manually).

For Mac users, the easiest and recommended way to get Docker Compose is to 
[install Docker Desktop](https://docs.docker.com/desktop/install/mac-install/). While this is enough to get the 
application running, you should request membership to the Penn Libraries Docker Team license 
from [the IT Helpdesk](https://ithelp.library.upenn.edu/support/home) for full functionality.

#### Development Credentials
 
Building the Vagrant environment should pull in the needed development key. If using the Vagrant environment for development, all secret values will be pulled from Vault. 

Settings files are, and should continue to be, structured to support credentials being made available by different means. For example, the Alma API keys is available via `DockerSecrets` in the Vagrant environment, but via the encrypted credential file when not using the Vagrant environment.

New credential values added to the Settings should be added **BOTH** to the Penn Vault as well as the encrypted Rails `development.yml.enc` file. This can be done with:

```bash
EDITOR=nano bundle exec rails credentials:edit -e development
```

### Starting App Services

Helpful Rake tasks have been created to wrap up the initialization process for the development environment. Prior to
starting this app, ensure you have a copy of the Solr configset and some sample data from another developer or by 
running the appropriate commands in the `catalog-indexing` project and copying those files into the `solr` directory.
For more information, see [Loading Data](#loading-data).

```
# start the app docker services, provision Solr collections and databases if not present, and run database migrations
rake tools:start

# stop docker services
rake tools:stop

# remove docker containers
rake tools:clean
```

### Loading Data

The `rake tools:start` command should ensure that the latest Solr config and sample data set ae loaded. Prior to running
this task, ensure you have a copy of the Solr configset as a zip file as well as a sample records `jsonl` file in the
`solr` directory. If the Solr container doesn't already have collections created, the `tools:start` command will attempt
to create new collections using the newest `configset_*.zip` file in the `solr` directory, then load the records in the 
newest `solrjson_*.jsonl` file in the `solr` directory.

### Developing

#### Install dependencies

```bash
bundle install
```

##### Postgres
For MacOS users the `pg` gem may fail to install with an error concerning the `libpq` library.

[Refer to this gist](https://gist.github.com/tomholford/f38b85e2f06b3ddb9b4593e841c77c9e) to address this issue.

#### Search Enhancements
This branch is an experiment in using LLMs to expand a user's query with related subjects pulled from our subject facets.
We could surface these subjects as recommendations or to help out when no results are found. The search builder method
used here hijacks the solr request and makes a subject facet search for ALL queries, so things may be a little weird. The
best way to test it out is to find a meaningful search that does not normally return any results and see what results pop up. I haven't yet
configured the blacklight parameters to match up with the chosen subjects, so you can click into a record and look at the subject facets that way.

Here are the dependencies introduced:

##### pgvector
This branch uses [pgvector](https://github.com/pgvector/pgvector), the
[pgvector gem](https://github.com/pgvector/pgvector-ruby), and [neighbor gem](https://github.com/ankane/neighbor) to facilitate vector storage and searching.

I had to install `pgvector` using `homebrew` on MacOS. There is a migration to enable to vector extension, but I am not sure if and how it
actually works! After installing pgvector, I connected to the `find-development` database using `psql` to create the extension.

```
$ psql cli

CREATE EXTENSION vector;
```

You can confirm the extension is available using the `psql` `\dx` command.

##### ollama

The LLM server runs locally using a [dockerized ollama](https://hub.docker.com/r/ollama/ollama) server. If you'd like, you can talk to
it, once you've started the app services, on port 11434 and with docker using `docker exec -it rails_app-ollama-1 ollama run llama3`. You can replace 'llama3' with
another model.

Ollama provides [useful embeddings documentation](https://ollama.com/blog/embedding-models). I've used the `all-minilm` and it's set up as the default for the embeddings service.

##### Subject Embeddings

You can generate Subject embeddings using the rake task `bundle exec rake search_enhancements:generate_sample_subjects`.
This generates Subject embeddings in the postgres database that we search against to find closest subjects related to a query.

#### Start the development server

```bash
bundle exec rails server
```
 
View the app at `localhost:3000`

#### Start the development server in RubyMine

In order for Rubymine to properly identify your Rails executable, you should open the project in the `rails_app` directory. Additionally, you will have to edit your run configuration to include the following environment variable: `BUNDLE_IGNORE_CONFIG=true`. Details about this can be found in the [top-level README](README.md). 

Assuming you have configured your Ruby SDK (to use `rbenv` or `asdf`) in RubyMine, you should be able to run the Rails server from the IDE. If you'd like to run the server in debugging mode, Rubymine will prompt you to install the necessary debugging gems if you have not already done so.

### Updating Blacklight

In order to mitigate the potential for issues when updating Blacklight versions, all overridden Blacklight classes and templates should include documentation about the version from which the copied class or overriden template started from. This should help to ensure that our overrides continue to function as expected as we update Blacklight.

When updating Blacklight, it is recommended to review each override and adapt to any changes in the latest version of the source file of the override, if needed. If no changes are needed, update the referenced version number in the override file documentation to reflect that it was reviewed for compatibility with the version of Blacklight being updated to.

It can be helpful to use [GitHub's comparison tool](https://github.com/projectblacklight/blacklight/compare/v8.8.0...v8.11.0) with the original and target versions specified, so that all changed files are easily reviewable.

## Contributing

In order to contribute productively while fostering the project values, familiarize yourself with the established
[Gitlab Collaboration Workflow](https://upennlibrary.atlassian.net/wiki/spaces/DLD/pages/498073672/GitLab+Collaboration+Workflow)
as well as the [Ruby on Rails Development Guidelines](https://upennlibrary.atlassian.net/wiki/spaces/DLD/pages/495616001/Ruby-on-Rails+Development+Guidelines).

### Running the Test Suite

When adding new features, be sure to consider the need for test coverage.

Run the full application test suite with:

```bash
bundle exec rspec
```

## Rubocop

This application uses Rubocop to enforce Ruby and Rails style guidelines. We centralize our UPenn specific configuration in
[upennlib-rubocop](https://gitlab.library.upenn.edu/dld/upennlib-rubocop).

If there are rubocop offenses that you are not able to fix please do not edit the rubocop configuration instead regenerate the `rubocop_todo.yml` using the following command:

```bash
rubocop --auto-gen-config  --auto-gen-only-exclude --exclude-limit 10000
```

To change our default Rubocop config please open an MR in the `upennlib-rubocop` project.
