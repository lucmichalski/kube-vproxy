#!/bin/bash
#
# Simple benchmark test suite
#
# You must have installed vegeta:
# go get github.com/tsenart/vegeta
#

go get -u github.com/tsenart/vegeta
host="http://localhost:81"
sudo ../kube-vproxy -apiInterface=0.0.0.0 -interface=0.0.0.0 -etcd=http://127.0.0.1:2379 -etcdKey=vulcand -port=81 -apiPort=8183 &
echo "VMX Reco ------------------------------------"
vegeta attack -body=./assets/test1.jpg -targets=targets.txt | tee results.bin | vegeta report -reporter="hist[0,100ms,200ms,300ms,400ms,500ms,600ms,700ms,800ms,900ms,1000ms]"
