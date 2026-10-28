# Find - Frontend

See the [README](rails_app/README.md) for the Rails app for more information about the application.

We support [a Taskfile and Docker development environment](#development-environment) as well as [a development environment using local Ruby and docker services](#working-with-local-services-in-docker). Choose your poison.

1. [Relation to other Projects](#relation-to-other-projects)
2. [Development Environment](#development-environment)
   - [Installing](#installing)
   - [Starting](#starting)
   - [Interacting with Environment](#interacting-with-environment)
   - [Interacting with Application](#interacting-with-application)
   - [Loading Sample Data](#loading-sample-data)
   - [Services](#services)
   - [Destroying](#destroying)
3. [Working with local services in Docker](#working-with-local-services-in-docker)
   1. [Initializing](#initializing)
4. [Working with a remote Solr index](#working-with-a-remote-solr-index)
5. [Design System](#design-system)

## Relation to other Projects

In deployed environments, Find is configured to point at a Solr index that is built and maintained by the [catalog-indexing](https://gitlab.library.upenn.edu/dld/catalog/catalog-indexing) app.

## Development Environment
The development environment is based on Taskfile and Docker. `task up` creates a Docker-in-Docker container that runs within it the application container and any related services.

### Installing
1. Install [Taskfile](https://taskfile.dev/), via one of the supported package managers.

    **For Linux:** Use [installation instructions](https://taskfile.dev/docs/installation) for your preferred package manager.

    **For Mac**: Install via homebrew, `brew install go-task`.

2. Install Docker.

    **For Mac:** [Install Docker Desktop](https://docs.docker.com/desktop/install/mac-install/). While this is enough to get the application running, you should request membership to the Penn Libraries Docker Team license from [the IT Helpdesk](https://ithelp.library.upenn.edu/support/home) for full functionality.

    **For Linux:** [Install docker engine](https://docs.docker.com/engine/install/).

### Starting

1. After installing Docker and Taskfile, move into the `.dev` directory:
    ```
    cd .dev
    ```

2. Then, run a task to start up the environment:
    ```
    task up
    ```

    When you first run a task command it will pull down a series of remote taskfiles, you'll need to answer `Y` to accept the alert/s.

    While the task runs, it will ask you for your computer password to update the `/etc/hosts` file and for your LDAP credentials to pull down secrets from Hashicorp Vault.

3. Once the environment has completed building, you'll be able to confirm the application is running by going to [https://catalog-find-dev.library.upenn.edu/](https://catalog-find-dev.library.upenn.edu/).

4. Move to the next sections for more details on how to interact with the environment.

### Interacting with Environment
When the environment is running, you can run the following command to swap the docker context.
```
task docker:context:use:app
```

After swapping the docker context, you'll be able to interact with the containers locally as if you were within the Docker-in-Docker container. Running commands like `docker ps` will display all the containers currently running in the environment.

When you are done you can change the context back to the default by running:
```
task docker:context:use:default
```

### Interacting with Application
Once your environment is set up:
1. Swap the docker context (see [Interacting with Environment](#interacting-with-environment)):
    ```
    task docker:context:use:app
    ```
2. Start a shell in the `catalog-find` app container:
    ```
    docker exec -it catalog-find_catalog_find.1.{whatever} sh
    ```

See the [Rails application README](rails_app/README.md) for information about running the test suite and general application development.

#### Locally build image
Usually the image for the Rails application is pulled from our gitlab registry. In some instances you may want to force the image to be built locally. In order to do that the `catalog_find_build_docker_image` variable in [ansible/inventories/development/group_vars/docker_swarm_managers/catalog-find.yml](ansible/inventories/development/group_vars/docker_swarm_managers/catalog-find.yml) must be set to `true`.

### Loading Sample Data

To index some sample records into the Solr instance:

1. Start a shell in the find app, see [Interacting with Application](#interacting-with-application)
2. Run rake tasks:
```bash
bundle exec rake tools:index_sample_file
```

### Services
- Rails Application
    - URL: [https://catalog-find-dev.library.upenn.edu/](https://catalog-find-dev.library.upenn.edu/)
- Solr (the configset is copied from the `catalog-indexing` repository when the environment starts)
    - URL: [http://catalog-find-dev.library.upenn.int/solr/#/](http://catalog-find-dev.library.upenn.int/solr/#/)
    - Username: `admin`
    - Password: `password`
- Postgres
- Chrome (for running system tests)

### Destroying
To destroy the environment and any data associated with it, run:
```
task destroy
```

## Working with local services in Docker

> __Important Note:__ The available Taskfile development environment relies on a Bundler configuration that houses the installed gems in the `vendor/bundle` directory.
> If you want to use local services, and a local Ruby interpreter (via `rbenv`, `asdf` or somesuch), you'll need to instruct bundler to ignore this configuration when running commands with `bundle` (including `bundle exec`).
> 
> To ignore the container-specific Bundler config in a terminal session, run `export BUNDLE_IGNORE_CONFIG=true`. Alternatively, you can prepend the environment variable with each command; e.g. `BUNDLE_IGNORE_CONFIG=true bundle exec rails c`.

### Initializing

Guidance for working in this environment - with the above provision - can be found in the [Rails App README file](rails_app/README.md).

## Working with a remote Solr index

1. Using Wireguard VPN...
2. Get a deployed Solr collection URL complete with included basic auth credentials. Somethings like: `http://staging-admin:staging-solr-pw@catalog-manager-stg01.library.upenn.int/solr1/catalog-staging`.
3. Add a local settings file at `rails_app/config/settings.local.yml` that defines a `solr_url` setting with the deployed Solr URL.
4. In the Taskfile environment, restart the Rails server by running `touch tmp/restart.txt` command in the running `catalog-find_catalog_find` container.
5. DO NOT run any SolrTools methods that are going to modify the deployed Solr collection!

## Design System

In the `Settings` file, the `pennlibs_web_version` value controls the [version of the Penn Libraries design system](https://gitlab.library.upenn.edu/dld/design/web-components/-/releases) assets (Javascript and Stylesheet) that will be [loaded in the application](https://upennlibrary.atlassian.net/wiki/spaces/designsystem/pages/741474353/Get+started) layout. Currently this configuration allows for minor and patch releases to be effective automatically, but it can be modified to pin a specific release.
