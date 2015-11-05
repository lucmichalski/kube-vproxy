#!/bin/bash
openssl req -x509  -batch -nodes -newkey rsa:2048 \
-keyout logstash/conf/logstash-forwarder.key \
-out logstash/conf/logstash-forwarder.crt \
-subj /CN=kube_svc_metrics_logstash
cp logstash/conf/logstash-forwarder.crt forwarder/ssl/logstash-forwarder.crt
cp logstash/conf/logstash-forwarder.key forwarder/ssl/logstash-forwarder.key
docker-compose stop
docker-compose build
docker-compose -f cluster_kubeMetrics.docker-compose.yml up -d
curl -XPUT svc_kube_metrics_elastic:9200/_template/aws_billing -d "`cat ./kube-templates/aws-billing-es-template.json`"
docker-compose logs svc_kube_metrics_forwarder
