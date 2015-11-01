#!/usr/bin/env bash

# Wait for the Elasticsearch container to be ready before starting Kibana.
echo "Waiting for Kube Vision - Elasticsearch Service"
while true; do
    nc -q 1 svc_kube_metrics_elastic 9200 >/dev/null && break
    sleep 5
done

echo "Starting Kube Vision - Kibana"
/opt/kibana/bin/kibana
