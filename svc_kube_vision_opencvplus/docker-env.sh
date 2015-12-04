#!/bin/bash
docker rmi $(docker images | grep "^<none>" | awk '{print $3}')
docker build -t server:dev -f linux-small.Dockerfile .
