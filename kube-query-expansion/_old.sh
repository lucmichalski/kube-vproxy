#!/bin/bash

#
# Luc Michalski - 2015
# Visual Proxy
#
VMX1_HOSTNAME=kube-master.blippar-vision.com
VMX1_PORT=3003

VMX2_HOSTNAME=kube-master.blippar-vision.com
VMX2_PORT=3001

model="maxfactor"
BACKEND="batch_maxfactor"

ENDPOINT_MIDDLEWARE="/api/v1/middleware/$BACKEND"
port=3003

CONTEXT="Maxfactor campaign europe 2015"

# temporary name for this middleware
vbundle init --middleware=github.com/blippar/kube-vproxy-vmx/transform
#vbundle init --middleware=github.com/blippar/kube-middlewares/visionai-vmx
#vbundle init --middleware=github.com/blippar/kube-middlewares/open-ocr
#vbundle init --middleware=github.com/blippar/kube-middlewares/open-face
#vbundle init --middleware=github.com/blippar/kube-middlewares/ltu-7.6.3
#vbundle init --middleware=github.com/blippar/kube-middlewares/batch
#vbundle init --middleware=github.com/blippar/kube-middlewares/enrichment

etcd&

go build -o kube-vproxy-macosx .
cp -f patch/fix.go vctl/main.go
pushd vctl/ && go build -o vctl && popd
vbundle init --middleware=github.com/blippar/kube-vproxy-vmx/transform
GOOS=linux CGO_ENABLED=0 go build -a -installsuffix cgo -o kube-vproxy-linux .
cp -f patch/fix.go vctl/main.go
pushd vctl/ && go build -o vctl && popd
mv -f kube-vproxy-linux bin/kube-vproxy-linux
mv -f kube-vproxy-macosx bin/kube-vproxy-macosx

# Will be fck gangsta more dynamic soon ! Chaaaaataaaa !
TEMPLATE=$(cat templates/vmx1.json | base64)
cat ./templates/vmx1.json | jq .
SESSIONS=`curl http://$VMX1_HOSTNAME:$VMX1_PORT/session | jq -r '.data[] .id'`
ENDPOINTS=""
for i in $(echo $SESSIONS | tr " " "\n")
do
  ENDPOINTS+="http://$VMX1_HOSTNAME:$VMX1_PORT/session/$i#vmx1,"
  # process
done
BATCH=$(echo -n $ENDPOINTS | sed "s/\(.*\).\{1\}/\1/")
echo $BATCH

SESSIONS=`curl http://$VMX2_HOSTNAME:$VMX2_PORT/sessions | jq -r '.data[] .id'`
ENDPOINTS=""
for i in $(echo $SESSIONS | tr " " "\n")
do
  ENDPOINTS+="http://$VMX2_HOSTNAME:$VMX2_PORT/sessions/$i#vmx2,"
  # process
done
BATCH+=","
BATCH+=$(echo -n $ENDPOINTS | sed "s/\(.*\).\{1\}/\1/")

etcdctl rm --recursive --dir /vulcand

BCK_CREATE=$(etcdctl set /vulcand/backends/bck_$model/backend \
"{\"Id\":\"bck_"$model"\",\"Type\":\"http\"}")
echo $BCK_CREATE | jq .
echo "backend output"
etcdctl ls --recursive

SRV_CREATE=$(etcdctl set /vulcand/backends/bck_$model/servers/srv_$model \
"{\"Id\":\"srv_"$model"\",\"URL\":\"http://127.0.0.1:"$port"\"}")
echo $SRV_CREATE | jq .
etcdctl ls --recursive

FRONT_CREATE=$(etcdctl set /vulcand/frontends/front_$model/frontend \
"{\"Id\":\"front_"$model"\",\"Type\":\"http\",\"BackendId\": \"bck_"$model"\",\"Route\": \"PathRegexp(\\\"$ENDPOINT_MIDDLEWARE.*\\\")\"}")
echo $FRONT_CREATE | jq .
echo "front-end output"
etcdctl ls --recursive

# Add the middleware
MIDDLEWARE=$(etcdctl set /vulcand/frontends/front_$model/middlewares/transformation \
"{
    \"Type\": \"transform\",
    \"Middleware\": {
        \"Template\": \""$TEMPLATE"\",
        \"Batch\": \""$BATCH"\",
        \"ActiveEngines\": \"vmx2,vmx1,ltu763\",
	\"ParseScore\": \"vmx2=\\\"data\\\",\\\"objects\\\",\\\"0\\\",\\\"score\\\"|vmx1=\\\"objects\\\",\\\"0\\\",\\\"score\\\"|ltu76=\\\"images\\\",\\\"0\\\",\\\"score\\\"\",
        \"ParseMeta\": \"vmx2=\\\"data\\\",\\\"objects\\\",\\\"0\\\",\\\"name\\\"|vmx1=\\\"objects\\\",\\\"0\\\",\\\"name\\\"|ltu76=\\\"images\\\",\\\"0\\\",\\\"keywords\\\"\",
        \"ParseBB\": \"vmx2=\\\"data\\\",\\\"objects\\\",\\\"0\\\",\\\"bb\\\"|vmx1=\\\"objects\\\",\\\"0\\\",\\\"bb\\\"|ltu76=\\\"images\\\",\\\"0\\\",\\\"result_info\\\",\\\"reference\\\",\\\"matchingBox\\\",\\\"points\\\"\",
        \"MarkerId\": 1234,
        \"BlippId\": 1234,
        \"Context\": \"test\",
        \"Width\": 320,
        \"Height\": 240,
        \"Learn\": 0,
        \"Concurrency\": 150,
        \"Transformation\": \"\",
        \"Nudity\": \"detect\",
        \"Chained\": 0,
        \"MinScore\": 0.5
    }
}")

echo "{
    \"Type\": \"transform\",
    \"Middleware\": {
        \"Template\": \""$TEMPLATE"\",
        \"Batch\": \""$BATCH"\",
        \"ActiveEngines\": \"vmx2,vmx1,ltu763\",
        \"ParseScore\": \"vmx2=\\\"data\\\",\\\"objects\\\",\\\"0\\\",\\\"score\\\"|vmx1=\\\"objects\\\",\\\"0\\\",\\\"score\\\"|ltu76=\\\"images\\\",\\\"0\\\",\\\"score\\\"\",
        \"ParseMeta\": \"vmx2=\\\"data\\\",\\\"objects\\\",\\\"0\\\",\\\"name\\\"|vmx1=\\\"objects\\\",\\\"0\\\",\\\"name\\\"|ltu76=\\\"images\\\",\\\"0\\\",\\\"keywords\\\"\",
        \"ParseBB\": \"vmx2=\\\"data\\\",\\\"objects\\\",\\\"0\\\",\\\"bb\\\"|vmx1=\\\"objects\\\",\\\"0\\\",\\\"bb\\\"|ltu76=\\\"images\\\",\\\"0\\\",\\\"result_info\\\",\\\"reference\\\",\\\"matchingBox\\\",\\\"points\\\"\",
        \"MarkerId\": 1234,
        \"BlippId\": 1234,
        \"Context\": \"test\",
        \"Width\": 320,
        \"Height\": 240,
        \"Learn\": 0,
        \"Concurrency\": 150,
        \"Transformation\": \"\",
        \"Nudity\": \"detect\",
        \"Chained\": 0,
        \"MinScore\": 0.5
    }
}"
echo $MIDDLEWARE | jq .
etcdctl ls --recursive

sudo ./bin/kube-vproxy-macosx -apiInterface=0.0.0.0 -interface=0.0.0.0 -etcd=http://127.0.0.1:2379 -etcdKey=vulcand -port=81 -apiPort=8183
