# Find - Frontend

See the [README](rails_app/README.md) for the Rails app for more information about the application.

## Relation to other Projects

TODO

## Working with the Vagrant environment

> Caveat: The vagrant development environment has only been tested in the local environments our developers currently have. This currently includes Linux, Intel-based Macs and M1 Macs.

In order to use the integrated development environment you will need to install [Vagrant](https://www.vagrantup.com/docs/installation) [do *not* use the Vagrant version that may be available for your distro repository - explicitly follow instructions at the Vagrant homepage] and the appropriate virtualization software. If you are running Linux or Mac x86 then install [VirtualBox](https://www.virtualbox.org/wiki/Linux_Downloads), if you are using a Mac with ARM processors then install [Parallels](https://www.parallels.com/).

You may need to update the VirtualBox configuration for the creation of a host-only network. This can be done by creating a file `/etc/vbox/networks.conf` containing:

```
* 10.0.0.0/8
```

### Starting

From the [vagrant](vagrant) directory run:

if running with Virtualbox:
```
vagrant up --provision
```

if running with Parallels:
```
vagrant up --provider=parallels --provision
```

This will run the [vagrant/Vagrantfile](vagrant/Vagrantfile) which will bring up an Ubuntu VM and run the Ansible script which will provision a single node Docker Swarm behind nginx with a self-signed certificate to mimic a load balancer. Your hosts file will be modified; the domain `apotheca-dev.library.upenn.edu` will be added and mapped to the Ubuntu VM. Once the Ansible script has completed and the Docker Swarm is deployed you can access the application by navigating to [https://apotheca-dev.library.upenn.edu](https://apotheca-dev.library.upenn.edu).

### Stopping

To stop the development environment, from the `vagrant` directory run:

```
vagrant halt
```

### Destroying

To destroy the development environment, from the `vagrant` directory run:

```
vagrant destroy -f
```

### SSH

You may ssh into the Vagrant VM by running:

```
vagrant ssh
```

#### Vagrant Services

1. [The Find Rails app]()
2. [Solr]()
3. [Postgres]()
4. [Chrome]()

## Working with local services in Docker

TODO

## Working with a remote Solr index

TODO (change `rails_app/config/blacklight.yml` to remote solr URL and restart app server. must use Wireguard. Don't nuke the index (SolrTools).)