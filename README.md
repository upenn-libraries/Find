# Find - Frontend

See the [README](rails_app/README.md) for the Rails app for more information about the application.

We are working to support [development in a Vagrant environment](#working-with-the-vagrant-environment) as well as [a development environment using local Ruby and docker services](#working-with-local-services-in-docker). Choose your poison.

1. [Relation to other Projects](#relation-to-other-projects)
2. [Developing](#developing)
   1. [Working with the Vagrant environment](#working-with-the-vagrant-environment)
      1. [Vagrant Services](#vagrant-services)
      2. [Starting](#starting)
      3. [Stopping](#stopping)
      4. [Destroying](#destroying)
      5. [SSH](#ssh)
      6. [Interacting with the Rails Application](#interacting-with-the-rails-application)
      7. [Loading Sample Data](#loading-sample-data)
   2. [Working with local services in Docker](#working-with-local-services-in-docker)
      1. [Initializing](#initializing)
3. [Working with a remote Solr index](#working-with-a-remote-solr-index)
## Relation to other Projects

In deployed environments, Find is configured to point at a Solr index that is built and maintained by the [catalog-indexing](https://gitlab.library.upenn.edu/dld/catalog/catalog-indexing) app.

## Developing

### Working with the Vagrant environment

> Caveat: The vagrant development environment has only been tested in the local environments our developers currently have. This currently includes Linux, Intel-based Macs and M1 Macs.

In order to use the integrated development environment you will need to install [Vagrant](https://www.vagrantup.com/docs/installation) [do *not* use the Vagrant version that may be available for your distro repository - explicitly follow instructions at the Vagrant homepage] and the appropriate virtualization software. If you are running Linux or Mac x86 then install [VirtualBox](https://www.virtualbox.org/wiki/Linux_Downloads), if you are using a Mac with ARM processors then install [Parallels](https://www.parallels.com/).

You may need to update the VirtualBox configuration for the creation of a host-only network. This can be done by creating a file `/etc/vbox/networks.conf` containing:

```
* 10.0.0.0/8
```
#### Vagrant Services

1. [The Find Rails app](https://catalog-find-dev.library.upenn.edu/)
2. [Solr](https://catalog-find-dev.library.upenn.int/solr/#/)
3. Postgres
4. Chrome (for running system tests)

#### Starting

From the [vagrant](vagrant) directory run:

if running with Virtualbox:
```
vagrant up --provision
```

if running with Parallels:
```
vagrant up --provider=parallels --provision
```

This will run the [vagrant/Vagrantfile](vagrant/Vagrantfile) which will bring up an Ubuntu VM and run the Ansible script which will provision a single node Docker Swarm behind nginx with a self-signed certificate to mimic a load balancer. Your hosts file will be modified; the domain `catalog-find-dev.library.upenn.edu` will be added and mapped to the Ubuntu VM. Once the Ansible script has completed and the Docker Swarm is deployed you can access the application by navigating to [https://catalog-find-dev.library.upenn.edu/](https://catalog-find-dev.library.upenn.edu/).

#### Stopping

To stop the development environment, from the `vagrant` directory run:

```
vagrant halt
```

#### Destroying

To destroy the development environment, from the `vagrant` directory run:

```
vagrant destroy -f
```

#### SSH

You may ssh into the Vagrant VM by running:

```
vagrant ssh
```

#### Interacting with the Rails Application

Once your vagrant environment is set up you can ssh into the vagrant box to interact with the application:

1. Enter the Vagrant VM by running `vagrant ssh` in the `/vagrant` directory
2. Start a shell in the `find` container:
```
  docker exec -it catalog-find_catalog_find.1.{whatever} sh
```

#### Loading Sample Data

To index some same records into the Solr instance:

1. Start a shell in the find app, see [interacting-with-the-rails-application](#interacting-with-the-rails-application)
2. Run rake tasks:
```bash
bundle exec rake tools:index_sample_file
```

## Working with local services in Docker

> __Important Note:__ The available Vagrant environment relies on a Bundler configuration that houses the installed gems in the `vendor/bundle` directory.
> If you want to use local services, and a local Ruby interpreter (via `rbenv`, `asdf` or somesuch), you'll need to instruct bundler to ignore this configuration when running commands with `bundle` (including `bundle exec`).
> 
> To ignore the vagrant-specific Bundler config in a terminal session, run `export BUNDLE_IGNORE_CONFIG=true`. Alternatively, you can prepend the environment variable with each command; e.g. `BUNDLE_IGNORE_CONFIG=true bundle exec rails c`.

### Initializing

Guidance for working in this environment - with the above provision - can be found in the [Rails App README file](rails_app/README.md).

## Working with a remote Solr index

1. Using Wireguard VPN...
2. Get a deployed Solr collection URL complete with included basic auth credentials. Somethings like: `http://staging-admin:staging-solr-pw@catalog-manager-stg01.library.upenn.int/solr1/catalog-staging`.
3. Add a local settings file at `rails_app/config/settings.local.yml` that defines a `solr_url` setting with the deployed Solr URL.
4. In the Vagrant environment, restart the Rails server by running `touch tmp/restart.txt` command in the running `catalog-find_catalog_find` container.
5. DO NOT run any SolrTools methods that are going to modify the deployed Solr collection!
