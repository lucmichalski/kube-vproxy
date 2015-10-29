#!/usr/bin/env bash

# Upload a file to open-ocr
#
# Usage: upload.sh <url> <file> [mime]
#    eg: upload.sh http://10.0.0.1:8080/ocr-file-upload ocrimage image/png
#
# (with addition of CRLF around the json....) thanks to https://github.com/soulseekah/bash-utils/blob/master/google-drive-upload/upload.sh

set -e

BOUNDARY=`cat /dev/urandom | head -c 16 | xxd -ps`
MIME_TYPE="image/jpg"

VEGATA=$(echo "--$BOUNDARY \
Content-Type: $MIME_TYPE
Content-Disposition: attachment; file=\"./maxfactor.jpg\".
" \
&& cat ./maxfactor.jpg && echo "
--$BOUNDARY--")

echo -e "$VEGATA" >> vegeta.req
