# ENSL HLDS Dockerfile.

This repo is totally Work In Progress. I just dumped it here so others can benefit. Will be polished some beatiful day.

How to use:
* `make build` to build Docker image
* `make run` to start NS1 server at default port on localhost
* `make stop` to stop the NS1 server
* `make clean` to clean containers and images

Add any custom configs you want to to overlay directory.

Features:
* Basically installs HLDS + NS1 server + ENSL Plugin.
* Also adds log compression with LZ4.
* Optional argument to enable HLTV.
