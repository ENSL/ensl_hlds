# ENSL HLDS Docker container.

This repo is totally Work In Progress. I just put it here so others can benefit. Will be polished some nice day.

## Setup

1. Add any custom configs or plugins you want to to overlay directory.
1. If you need to change env. variables, copy `.env.default` to `.env` and change it.

### How to start:

    docker-compose up --build

### How to attach to console (replace CONTAINER_NAME with hlds or hltv):

    docker attach CONTAINER_NAME

### How to run shell in container:

    docker-compose exec CONTAINER_NAME /bin/bash

### How to stop:

    docker-compose down

## Other things

1. Demos and logs are found in demos and logs folder. If you get any permission errors run in repo root directory

    sudo chown -R 1000:100 demos logs

1. Run following command to renice the servers to maximum priority.

    bash ./scripts/renice.sh

1. ~~You can enable FPS record with HLDS_RECORD_FPS=1 in `.env`~~

## Support

You can ask for help in Discord: https://discord.gg/ZUSSBUA
Or send me email.

## Features

* Basically installs HLDS + NS1 server + ENSL Plugin.
* Also adds log compression with LZ4.
* Optional argument to enable HLTV.
