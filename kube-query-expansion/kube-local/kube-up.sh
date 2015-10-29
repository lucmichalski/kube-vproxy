#!/bin/bash

require_command_exists() {
    command -v "$1" >/dev/null 2>&1 || { echo "$1 is required but is not installed. Aborting." >&2; exit 1; }
}

require_command_exists kubectl
require_command_exists docker
require_command_exists docker-compose

docker info > /dev/null
if [ $? != 0 ]; then
    echo "A running Docker engine is required. Is your Docker host up?"
    exit 1
fi

cd kubernetes
docker-compose up -d

cd ../scripts

if [ $(command -v docker-machine) ] &&  [ ! -z "$(docker-machine active)" ]; then
    ./docker-machine-port-forwarding.sh
fi

./wait-for-kubernetes.sh
./activate-dns.sh
./activate-kube-ui.sh
./activate-kube-vproxy.sh
