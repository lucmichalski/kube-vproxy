#!/bin/bash

# Copyright 2014 The Kubernetes Authors All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# This script builds a configuration for Prometheus based on command line
# arguments and environment variables and starts the Prometheus server.
#
# Sample usage (to be run inside Kubernetes-created docker container).
#  ./run.sh -t KUBERNETES_RO -d /tmp/prometheus
#

show_usage() {
  echo "usage: $0 -t TARGET_1,TARGET_2 -d data_directory"
  echo "where"
  echo " -t List of services to be monitored. Each service T should be described by"
  echo "    the T_SERVICE_HOST and T_SERVICE_PORT env variables."
  echo "-d Prometheus' root directory (i.e. where config file/metrics data will be stored)."
}

build_config() {
  cat <<EOS
global:
  scrape_interval: 10s
  evaluation_interval: 10s

scrape_configs:
EOS
  local target
  local target_address

  ### Allow prometheus to scrape multiple targets
  ### i.e. -t KUBERNETES_RO,MY_METRICS_ABC
  for target in ${1//,/ }; do
    local target_address_variable="${target}_TARGET_ADDRESS"
    target_address=$(eval echo '$'$target_address_variable)
    if [ -z "${target_address}" ]; then
      local host_variable="${target}_SERVICE_HOST"
      local port_variable="${target}_SERVICE_PORT"
      local host=$(eval echo '$'$host_variable)
      local port=$(eval echo '$'$port_variable)
      if [ -z ${host} ]; then
        >&2 echo "No env variable for ${host_variable}."
        exit 3
      fi
      if [ -z ${port} ]; then
        >&2 echo "No env variable for ${port_variable}."
        exit 3
      fi
      target_address="${host}:${port}"
    fi
    cat <<EOS
- job_name: '${target}'
  target_groups:
  - targets: [ '${target_address}' ]
EOS
  done
}

while getopts :t:d: flag; do
  case $flag in
  t) # targets.
    targets=$OPTARG
    ;;
  d) # data location
    location=$OPTARG
    ;;
  \?)
    echo "Unknown parameter: $flag"
    show_usage
    exit 2
    ;;
  esac
done

if [ -z $targets ] || [ -z $location ]; then
  echo "Missing parameters."
  show_usage
  exit 2
fi

echo "------------------"
echo "Using $location as the root for prometheus configs and data."
mkdir -p $location
config="$location/prometheus.yaml"
storage="$location/storage"

echo "-------------------"
echo "Starting Prometheus with:"
echo "targets: $targets"
echo "config: $config"
echo "storage: $storage"

echo "config file:"
build_config $targets | tee $config
echo "-------------------"

exec /bin/prometheus \
  "-log.level=debug" \
  "-config.file=$config" \
  "-storage.local.path=$storage" \
  "-web.console.libraries=/go/src/github.com/prometheus/prometheus/console_libraries" \
  "-web.console.templates=/go/src/github.com/prometheus/prometheus/consoles"
