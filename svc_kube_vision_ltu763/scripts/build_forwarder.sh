#!/bin/sh

# Luc Michalski - 2015
# It was a nightmare to get a stable LTU environemnt dockerized then integrated into Kubernetes
# 11 October 2015 / New York

DOCKER=`which docker`
GIT=`which git`
CURL=`which curl`
LFSOURCE=lfsource
BUILD_GOOS=${BUILD_GOOS:-"linux"}
BUILD_GOARCH=${BUILD_GOARCH:-"amd64"}
for goos in $BUILD_GOOS; do
        for goarch in $BUILD_GOARCH; do
                echo "Building $name for $goos-$goarch"
		echo "Building logstash-forwarder.."
		rm -rf $LFSOURCE
		$GIT clone git://github.com/elasticsearch/logstash-forwarder.git $LFSOURCE
		cd $LFSOURCE
		echo "with Docker $(docker version)"
		$DOCKER run --rm \
	           --volume $PWD:/src \
	           --workdir /src \
	            -e UID=$(id -u) \
	            -e GID=$(id -g) \
		    -e GOOS=$goos \
		    -e GOARCH=$goarch \
	           quay.io/pires/alpine-linux-build \
	           go build -o logstash-forwarder-$goos-$goarch
		echo "Copying binaries"
		cd ..
		cp $LFSOURCE/logstash-forwarder-$goos-$goarch ./logstash-forwarder-$goos-$goarch
		chmod +x ./logstash-forwarder-$goos-$goarch
		./logstash-forwarder-$goos-$goarch --version
		rm -fR $LFSOURCE
        done
done

#echo "Cleaning sources.."
#rm -rf $LFSOURCE/*

echo "Done"
