#!/bin/bash

#
# Luc Michalski - 2015
#

docker stop ltu763docker
docker rm ltu763docker

echo "====================== LTU7.6 Container runing"
echo "Run the docker container to test the launch process"

echo "Quick notes:"
echo " - 1979 is for the Traefik reverse proxy endpoints"
echo " - 1980 is for the Web UI and teh Health Monitoring of the container"

docker stop ltu763docker; docker rm ltu763docker; docker run --name=ltu763docker --privileged=true -d \
                -p 0.0.0.0:1979:1979 \
                -p 0.0.0.0:1980:1980 \
                -v /opt/logs/features2d/ltu76:/opt/logs \
         lucmichalski/kubevision-ltu76-rest:batch-v1
