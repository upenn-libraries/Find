# Find - Frontend

See the [README](rails_app/README.md) for the Rails app for more information about the application.

We are working to support [development in a Vagrant environment](#working-with-the-vagrant-environment) as well as [a development environment using local Ruby and docker services](#working-with-local-services-in-docker). Choose your poison.

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



## Working with local services in Docker

> __Important Note:__ The available Vagrant environment relies on a Bundler configuration that houses the installed gems in the `vendor/bundle` directory.
> If you want to use local services, and a local Ruby interpreter (via `rbenv`, `asdf` or somesuch), you'll need to instruct bundler to ignore this configuration when running commands with `bundle` (including `bundle exec`).
> 
> To ignore the vagrant-specific Bundler config in a terminal session, run `export BUNDLE_IGNORE_CONFIG=true`. Alternatively, you can prepend the environment variable with each command; e.g. `BUNDLE_IGNORE_CONFIG=true bundle exec rails c`.

### Debugging in RubyMine

> In order for Rubymine to properly identify your Rails executable, you should open the project in in the `rails_app` directory. Assuming you have configured your Ruby SDK (to use `rbenv` or `asdf`) in RubyMine, you should be able to run the Rails server from the IDE. Rubymine will prompt you to install the necessary debugging gems if you have not already done so.

### Initializing

Guidance for working in this environment - with the above provision - can be found in the [Rails App README file](rails_app/README.md).

## Working with a remote Solr index

> TODO: This needs to be confirmed as functional

1. Using Wireguard VPN...
2. Get production Solr collection URL
3. Update [blacklight.yml](rails_app/config/blacklight.yml) `development.url` value to the above URL value, including any auth credentials
4. Restart the Rails server by running `touch tmp/restart.txt` command in the running `catalog-find_catalog_find` container
5. DO NOT commit this change OR run any SolrTools methods (TODO: don't trust anyone to actually follow this guidance)

