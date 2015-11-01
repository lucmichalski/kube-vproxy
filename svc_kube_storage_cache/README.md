# docker-redis-cluster

Docker image with redis built and installed from source.

The main usage for this container is to test redis cluster code. For example in https://github.com/Grokzen/redis-py-cluster repo.

The cluster is 6 redis instances running with 3 master & 3 slaves, one slave for each master. They run on ports 7000 to 7005.

It also contains 2 standalone instances that is not part of the cluster. They are running on port 7006 & 7007

It will allways build the latest commit in the 3.0 branch  `https://github.com/antirez/redis/tree/3.0`

This image requires `Docker` above version 1.0



# Usage

If you want to use `docker-compose (fig)` please read next section.

Either download the latest build from docker hub with `docker pull grokzen/redis-cluster`

Or to build the image, use either `make build` or `make rebuild`. It will be built to the image name `grokzen/redis-cluster`.

To start the image use `make run`. It will be started in the background. To gain access to the running image you can get a bash session by running `make bash`.

Redis cli can be used with `make cli` to gain access to one of the cluster servers.



# Docker compose (fig)

This image contains a `compose.yml` file that can be used with `docker-compose (fig)` to run the image. Docker compose is simpler to use then the old `Makefile`.

Build the image with `docker-compose -f compose.yml build`.

Start the image after building with `docker-compose -f compose.yml up`. Add `-d` to run the server in background/detatched mode.



# Known Issues

If you get a error when rebuilding the image that docker can't do dns lookup on `archive.ubuntu.com` then you need to modify docker to use google IPv4 DNS lookups. Read the following link http://dannytsang.co.uk/docker-on-digitalocean-cannot-resolve-hostnames/ and uncomment the line in `/etc/default/docker` and restart your docker daemon and it should be fixed.
