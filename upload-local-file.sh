#!/usr/bin/env bash

# Upload a file to open-ocr
#
# Usage: upload.sh <url> <file> [mime]
#    eg: upload.sh http://10.0.0.1:8080/ocr-file-upload ocrimage image/png
#
# (with addition of CRLF around the json....) thanks to https://github.com/soulseekah/bash-utils/blob/master/google-drive-upload/upload.sh

set -e

URL="http://192.168.99.100:9292/ocr-file-upload"
FILE=${1}
if [ ! -f "${FILE}" ]; then
	echo "ERROR: cannot find file: '${FILE}'"
	exit 42
fi

BOUNDARY=`cat /dev/urandom | head -c 16 | xxd -ps`
MIME_TYPE=${3:-"image/png"}

( echo "--$BOUNDARY
Content-Type: application/json; charset=UTF-8

{ \"engine\": \"tesseract\", \"preprocessors\":[\"stroke-width-transform=1\"] }

--$BOUNDARY
Content-Type: $MIME_TYPE
Content-Disposition: attachment; filename=\"attachment.txt\".
" \
&& cat $FILE && echo "
--$BOUNDARY--" ) \
	| curl -v -L -X POST "$URL" \
	--header "Content-Type: multipart/related; boundary=\"$BOUNDARY\"" \
	--data-binary "@-"

# if you want to use the stroke-width-transform preprocessor then swap the line:
# 
# { \"engine\": \"tesseract\" }
#
# With:
#
# { \"engine\": \"tesseract\", \"preprocessors\":[\"stroke-width-transform\"] }
#
