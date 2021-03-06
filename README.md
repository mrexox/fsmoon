# evesync
[![Build Status](https://travis-ci.org/mrexox/evesync.svg?branch=master)](https://travis-ci.org/mrexox/evesync)
[![codecov](https://codecov.io/gh/mrexox/evesync/branch/master/graph/badge.svg)](https://codecov.io/gh/mrexox/evesync)
[![Gem Version](https://badge.fury.io/rb/evesync.svg)](https://badge.fury.io/rb/evesync)

A simple ruby-written service for automation files and packages changes between similar hosts.

## Getting started
Using evesync is very simple. All you need - install dependent gems and start daemons.

### Prerequisites

You need to install all gems. This can be easily done by calling `bundle install`.

### Installing

#### From rubygems

For Rhel (CentOS, Fedora, etc.) users:

```
# yum install rubygems ruby-devel make gcc
# sudo gem install --no-user-install evesync
```

For Debian (Ubuntu, Puppet, etc.) users:

```
# apt-get update
# apt-get install rubygems ruby-dev make gcc
# sudo gem install --no-user-install evesync
```

#### Adding Systemd service

Create a file **/usr/lib/systemd/system/evesync.service** with following content:

```
[Unit]
Description=Evesync daemons
Documentation=Starting all evesync daemons. Logs can be found in /var/log/evesync.
After=network.target

[Service]
Type=forking
ExecStart=/usr/bin/evesync --run
ExecStop=/usr/bin/evesync --kill
PIDFile=/var/run/evesync/evemond.pid

[Install]
WantedBy=multi-user.target
```

Then just run:

```
# systemctl enable evesync.service
# systemctl start evesync.service
```

Don't forget to install gem with `--no-user-install` flag, to install it globally.

#### Manually

You need install the gem and place the script **bin/start** directory into any of your PATH-accessable folders. Or use **evesync --run**.

```bash
# Installing dependencies
bundle install --without development

# Test to make sure it works as expected
rake test

# Installing the gem
rake install
```

## Testing
There's the way to test without installing evesync on real systems. Using Docker.

### Starting containers with evesync service

```
docker-compose build
docker-compose up --detach
```

or

```
rake docker:build
rake docker:up
```

This will build the docker image for CentOS 7.4 distribution and start 2 of the containers.

When attached, you'll see tmux session. `bin/start` will start evesync service.

### Stopping containers

```
rake docker:down

```

or

```
docker-compose rm --force
```

For more information about realization see [description.md](./description.md)
