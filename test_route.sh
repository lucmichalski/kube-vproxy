#!/bin/bash
VMX1_HOSTNAME=kube-master.blippar-vision.com
VMX1_PORT=3003

# Kube VMX v2.x hostname + Port
VMX2_HOSTNAME=kube-master.blippar-vision.com
VMX2_PORT=3001
TEMPLATE=$(cat ./kube-query-expansion/templates/vmx1.json | base64)
cat ./kube-query-expansion/templates/vmx1.json | jq .
SESSIONS=`curl http://kube-master.blippar-vision.com:3003/session | jq -r '.data[] | "\(.model.name);\(.id)"'`
ENDPOINTS=""
for i in $(echo $SESSIONS | tr " " "\n")
do
  MODEL=`echo $i | cut -d \; -f 1`
  SESSION=`echo $i | cut -d \; -f 2`
  ENDPOINTS+="POST:vmx1:$MODEL://$VMX1_HOSTNAME:$VMX1_PORT/session/$SESSION|"
  # process
done
QUEUE=$(echo -n $ENDPOINTS | sed "s/\(.*\).\{1\}/\1/")

echo $QUEUE
