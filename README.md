# Find - A Penn Libraries Catalog

This application is the front end for the Penn Libraries catalog. It uses 
[Blacklight](https://github.com/projectblacklight/blacklight) to facilitate searching and display of records from a Solr
index. Records are harvested from our ILS (Alma) by the 
[`catalog-indexing`](https://gitlab.library.upenn.edu/dld/catalog/catalog-indexing) app, and parsing of MARC is handled 
by the [`pennmarc`](https://gitlab.library.upenn.edu/dld/catalog/pennmarc) gem 
([docs](https://rubygems.org/gems/pennmarc)).

Eventually, this app will also contain patron account management functionality.

## Starting App Services

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

## Developing

### Project Values

1. Excellent test coverage
2. Adherence to code style embodied in [`upennlib-rubocop`](https://gitlab.library.upenn.edu/dld/upennlib-rubocop)

### Running Tests

TODO

### Running Rubocop

```bash
rubocop
```
