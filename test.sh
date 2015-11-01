#!/bin/bash

files="$(find -L "./kube-assets/" -type f)"
echo "Count: $(echo -n "$files" | wc -l)"
SESSIONID="KUBE-QUERY-EXPANSION"
echo "$files" | while read file; do
  echo "$file"
  ./upload-local-file.sh $file
  curl -s -X POST -F "file"=@$file -F "region"="us" -F "sessionId"="$SESSIONID" http://192.168.99.100:81/api/v1/middleware/kubeFactor | jq .
done
