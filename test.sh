#!/bin/bash

files="$(find -L "./kube-assets" -type f)"
echo "Count: $(echo -n "$files" | wc -l)"
SESSIONID="KUBE-QUERY-EXPANSION"

curl -s -X POST -F "file"=@ocrimage -F "region"="us" -F "sessionId"="$SESSIONID" http://192.168.99.100:81/api/v1/middleware/kubeFactor | jq .

files="$(find -L "./kube-assets/maxfactor_tests/" -type f)"
echo "Count: $(echo -n "$files" | wc -l)"
SESSIONID="KUBE-QUERY-EXPANSION"
echo "$files" | while read file; do
  #echo "$file"
  curl -s -X POST -F "file"=@$file -F "region"="us" -F "sessionId"="$SESSIONID" http://192.168.99.100:81/api/v1/middleware/kubeFactor | jq .
done

files="$(find -L "./kube-assets/ocr_text/" -type f)"
echo "Count: $(echo -n "$files" | wc -l)"
SESSIONID="KUBE-QUERY-EXPANSION"
echo "$files" | while read file; do
  #echo "$file"
  curl -s -X POST -F "file"=@$file -F "region"="us" -F "sessionId"="$SESSIONID" http://192.168.99.100:81/api/v1/middleware/kubeFactor | jq .
done
