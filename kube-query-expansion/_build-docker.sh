#!/bin/bash
mkdir $HOME/.go
export GOPATH=$HOME/.go
export PATH=$PATH:$GOPATH/bin
vbundle init --middleware=github.com/blippar/kube-vproxy-vmx/transform
GOOS=linux CGO_ENABLED=0 go build -a -installsuffix cgo -o kube-proxy-linux .
cp -f patch/fix.go vctl/main.go
pushd vctl/ && go build -o vctl && popd
mv kube-vproxy-linux bin/kube-vproxy-linux
chmod +x kube-vproxy-linux
docker build -t lucmichalski/kube-vproxy:feature_middleware .
docker push lucmichalski/kube-vproxy:feature_middleware
