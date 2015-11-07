#!/bin/bash

#
# Luc Michalski - 2015
# Micro Service with Max Factor and logos products
#

files="$(find -L "../kube-assets/maxfactor-complexity" -type f)"
echo "Count: $(echo -n "$files" | wc -l)"
SESSIONID="KUBE-QUERY-EXPANSION"
echo "$files" | while read file; do
  echo "$file"
  curl -s -X POST -F "file"=@$file -F "region"="us" -F "sessionId"="$SESSIONID" http://$KUBE_VPROXY_IP:$KUBE_VPROXY_PORT/vmx | jq .
done

files="$(find -L "../kube-assets/logos-samples" -type f)"
echo "Count: $(echo -n "$files" | wc -l)"
SESSIONID="KUBE-QUERY-EXPANSION"
echo "$files" | while read file; do
  echo "$file"
  curl -s -X POST -F "file"=@$file -F "region"="us" -F "sessionId"="$SESSIONID" http://$KUBE_VPROXY_IP:$KUBE_VPROXY_PORT/vmx | jq .
done
