#
# Luc Michalski - 2015
# Kube-Vision
#
MAINTAINER Luc Michalski <luc.michalski@blippar.com>
FROM alpine:edge

RUN apk --update add go git \
	&& ORG_PATH="github.com/blippar/" \
	&& REPO_PATH="${ORG_PATH}kube-vproxy" \
	&& export GOPATH=/go \
	&& export PATH=$PATH:$GOPATH/bin \
	&& mkdir -p $GOPATH/src/${ORG_PATH} \
	&& ln -s ${PWD} $GOPATH/src/${REPO_PATH} \
	&& cd $GOPATH/src/${REPO_PATH} \

	&& go get github.com/vulcand/vulcand/Godeps/_workspace/src/github.com/vulcand/oxy/utils \
	&& go get github.com/vulcand/vulcand/Godeps/_workspace/src/github.com/codegangsta/cli \
	&& go get github.com/vulcand/vulcand/Godeps/_workspace/src/github.com/coreos/go-etcd/etcd \
	&& go get github.com/vulcand/vulcand/Godeps/_workspace/src/github.com/mailgun/log \
	&& go get github.com/vulcand/vulcand/vbundle \
    && go get github.com/rwcarlsen/goexif/exif \
	&& go get github.com/Financial-Times/vulcan-session-auth/sauth \
	&& go get github.com/mailgun/vulcand/vbundle \
	&& go get github.com/mailgun/log \
    && go get github.com/vulcand/oxy/forward \
    && go get github.com/vulcand/oxy/cbreaker \ 
    && go get github.com/vulcand/oxy/connlimit \
    && go get github.com/vulcand/oxy/forward \
    && go get github.com/vulcand/oxy/memmetrics \
    && go get github.com/vulcand/oxy/ratelimit \
    && go get github.com/vulcand/oxy/roundrobin \
    && go get github.com/vulcand/oxy/stream \
    && go get github.com/vulcand/oxy/trace \
    && go get github.com/vulcand/oxy/utils \
    && go get github.com/trajber/handy \
    && cd $GOPATH/src/ \
    && git clone https://github.com/vulcand/vulcand \
    && cd vulcand \
    && make install \
    && mkdir -p /go/src/github.com/blippar/kube-vproxy/kube-query-expansion/registry \
    && mkdir -p /go/src/github.com/blippar/kube-vproxy/kube-middlewares \
    && cp -Rf /go/src/app/kube-query-expansion/registry/registry.go /go/src/github.com/blippar/kube-vproxy/kube-query-expansion/registry/registry.go \
    && cp -Rf /go/src/app/kube-middlewares /go/src/github.com/blippar/kube-vproxy/ \
    && cd /go/src/app/kube-query-expansion \
    && rm main.go \
    && mv main.initial.go main.go \
    && cd vctl \        
    && go build . \
    && cd .. \
    && ls -l \
    && vbundle init --middleware=github.com/blippar/kube-vproxy/kube-middlewares/kubeDispatcher \
                 	--middleware=github.com/blippar/kube-vproxy/kube-middlewares/kubeLogos \ 
                 	--middleware=github.com/blippar/kube-vproxy/kube-middlewares/kubeVisualCache \ 
                 	--middleware=github.com/blippar/kube-vproxy/kube-middlewares/kubeOCR \ 
                 	--middleware=github.com/blippar/kube-vproxy/kube-middlewares/kubeConnect \
    && go build -v -o ./kube-vproxy . \
    && cp -f patch/fix.go vctl/main.go \
    && ls -l \  
    && /bin/bash -c 'pushd vctl/ && go build -o vctl && popd' \
    && cp /go/src/app/kube-query-expansion/kube-vproxy /go/bin/kube-vproxy
#	&& vbundle init --middleware=github.com/Financial-Times/vulcan-session-auth/sauth \
	&& apk del go git \
	&& rm -rf /var/cache/apk/*

EXPOSE 8181 8182
ENTRYPOINT ["/go/bin/kube-vproxy"]