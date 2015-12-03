#!/bin/bash
./find_object-tcpRequest --httpPort 1981&
cd ./tests
rm -f *.jpg
cd ..
files="$(find -L "../products/" -type f)"
echo "Count: $(echo -n "$files" | wc -l)"
echo "$files" | shuf | while read file; do
  curl -s -X POST -H "Content-Type: multipart/form-data" -F "file=@$file" http://localhost:1981/vmx | jq .
done
