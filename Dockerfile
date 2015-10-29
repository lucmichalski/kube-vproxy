FROM golang:1.5.1
MAINTAINER Luc Michalski <luc.michalski@blippar.com>
ENV GOPATH /go:/go/src/app/kube-query-expansion/Godeps/_workspace
ENV PATH $PATH:$GOPATH/bin
COPY . /go/src/app
WORKDIR /Users/lucmichalski/.go/src/github.com/blippar/kube-vproxy-plugins/

RUN     ls -l /go && \
	go get github.com/mailgun/log && \
	go get github.com/mailgun/vulcand/Godeps/_workspace/src/github.com/codegangsta/cli && \	
        go get github.com/mailgun/vulcand/vbundle && \
        go get github.com/tools/godep && \
	cd /go/src/ && \
        git clone https://github.com/mailgun/vulcand && \
	cd vulcand && \
	make install && \
        cd /go/src/app/kube-query-expansion && \
        rm main.go && \
        mv main.initial.go main.go && \
        cd vctl && \       	
        go build . && \
        cd .. && \
	ls -l && \
        vbundle init --middleware=github.com/blippar/kube-vproxy-plugins/kube-middlewares/kubeDispatcher \
                 --middleware=github.com/blippar/kube-vproxy-plugins/kube-middlewares/kubeOCR && \	
        go build -v -o ./kube-vproxy . && \
        cp -f patch/fix.go vctl/main.go && \
        ls -l && \	
        /bin/bash -c 'pushd vctl/ && go build -o vctl && popd' && \
       cp /go/src/app/kube-query-expansion/kube-vproxy /go/bin/kube-vproxy

EXPOSE 8181 8182
ENTRYPOINT ["/go/bin/kube-vproxy"]
