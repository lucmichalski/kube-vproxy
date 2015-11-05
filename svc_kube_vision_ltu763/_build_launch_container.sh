#!/bin/bash

echo ""
echo "======= Vision Kube - Dockerized LTU 7.63, Traefik 0.1, Mungehosts win a Centos 6.0 Distribution"
echo "======= Ready for being deployed into the vision Kube with Logstash Forwarder, Bulk Upload of markers (>10GB)"
echo "======= Luc Michalski - 2015"
echo ""

echo "====================== Docker space cleaning"
echo "- Remove all untagged images"
docker rmi -f $(docker images | grep "<none>" | awk "{print \$3}")

echo "- Remove all stopped containers"
docker rm `docker ps --no-trunc -aq`

echo "- Remove old volumes"
#docker run -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker:/var/lib/docker --rm martin/docker-cleanup-volumes

# Copy SSL certs for logstash forwarder
cp -f /opt/certs/logstash-forwarder.* ./certs/

echo "====================== LTU7.6 Container building"
echo "Build the docker container"
# Make optional to keep in cahce
# --no-cache=true
docker build --no-cache=true -t lucmichalski/kubevision-ltu763:batch-v2 .
echo ""

echo "====================== Inspect the image built"
docker inspect lucmichalski/kubevision-ltu763:batch-v2

echo "====================== LTU7.6 Container runing"
echo "Run the docker container to test the launch process"

echo "Quick notes:"
echo " - 1979 is for the Traefik reverse proxy endpoints"
echo " - 1980 is for the Web UI and teh Health Monitoring of the container"

docker stop ltu763docker;docker rm ltu763docker; 

docker run -d -ti --name=ltu763docker --privileged=true -p 0.0.0.0:1979:1979 -p 0.0.0.0:1980:1980 -p 0.0.0.0:1982:80 -p 0.0.0.0:8888:8888  lucmichalski/kubevision-ltu763:batch-v2
