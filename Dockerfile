FROM golang:1.5.1
MAINTAINER Luc Michalski <luc.michalski@blippar.com>
ENV GOPATH /go:/go/src/app/kube-query-expansion/Godeps/_workspace
ENV PATH $PATH:$GOPATH/bin
COPY . /go/src/app
WORKDIR /Users/lucmichalski/.go/src/github.com/blippar/kube-vproxy/

# Just for the time of the dev
RUN     ls -l /go && \
	go get github.com/vulcand/vulcand/Godeps/_workspace/src/github.com/vulcand/oxy/utils &&\
	go get github.com/vulcand/vulcand/Godeps/_workspace/src/github.com/codegangsta/cli && \
        go get github.com/vulcand/vulcand/Godeps/_workspace/src/github.com/coreos/go-etcd/etcd && \
	go get github.com/vulcand/vulcand/Godeps/_workspace/src/github.com/mailgun/log && \
        go get github.com/vulcand/vulcand/vbundle && \
	go get gopkg.in/throttled/throttled.v2/... && \
	go get github.com/rwcarlsen/goexif/exif && \
#        go get github.com/golang/net/proxy && \
#	go get github.com/golang/net/contex && \
        go get github.com/tools/godep && \
	go get github.com/trajber/handy && \
	go get github.com/gin-gonic/gin && \
	go get github.com/hyperboloide/pipe && \
	go get github.com/vulcand/oxy/forward && \
	go get github.com/vulcand/oxy/cbreaker && \	
        go get github.com/vulcand/oxy/connlimit && \
        go get github.com/vulcand/oxy/forward && \
	go get github.com/carbocation/interpose && \
        go get github.com/vulcand/oxy/memmetrics && \
        go get github.com/vulcand/oxy/ratelimit && \
        go get github.com/vulcand/oxy/roundrobin && \
        go get github.com/vulcand/oxy/stream && \
        go get github.com/vulcand/oxy/trace && \
        go get github.com/vulcand/oxy/utils && \
	cd /go/src/ && \
        git clone https://github.com/vulcand/vulcand && \
	cd vulcand && \
	make install && \
	mkdir -p /go/src/github.com/blippar/kube-vproxy/kube-query-expansion/registry && \
        mkdir -p /go/src/github.com/blippar/kube-vproxy/kube-middlewares && \
        cp -Rf /go/src/app/kube-query-expansion/registry/registry.go /go/src/github.com/blippar/kube-vproxy/kube-query-expansion/registry/registry.go && \
	cp -Rf /go/src/app/kube-middlewares /go/src/github.com/blippar/kube-vproxy/ && \
        cd /go/src/app/kube-query-expansion && \
        rm main.go && \
        mv main.initial.go main.go && \
        cd vctl && \       	
        go build . && \
        cd .. && \
	ls -l && \
        vbundle init --middleware=github.com/blippar/kube-vproxy/kube-middlewares/kubeDispatcher \
                 --middleware=github.com/blippar/kube-vproxy/kube-middlewares/kubeOCR \	
                 --middleware=github.com/blippar/kube-vproxy/kube-middlewares/kubeConnect  && \
        go build -v -o ./kube-vproxy . && \
        cp -f patch/fix.go vctl/main.go && \
        ls -l && \	
        /bin/bash -c 'pushd vctl/ && go build -o vctl && popd' && \
       cp /go/src/app/kube-query-expansion/kube-vproxy /go/bin/kube-vproxy

EXPOSE 8181 8182
ENTRYPOINT ["/go/bin/kube-vproxy"]
