#!/bin/bash
vbundle init --middleware=github.com/blippar/kube-vproxy/kube-middlewares/kubeDispatcher \
             --middleware=github.com/blippar/kube-vproxy/kube-middlewares/kubeOCR

go build -v -o test-osx .
cp -f patch/fix.go vctl/main.go
pushd vctl/ && go build -o vctl && popd
./test-osx
