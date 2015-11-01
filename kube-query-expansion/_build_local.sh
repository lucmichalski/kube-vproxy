#!/bin/bash

#
# Luc Michalski - 2015
# Visual Proxy

MIDDLEWARE_SETUP="kubeFactor"
MIDDLEWARE_DISPATCHER_NAME="kubeDispatcher"
MIDDLEWARE_OCR_NAME="kubeOCR"

# Kube VMX v1.x hostname + Port
VMX1_HOSTNAME=kube-master.blippar-vision.com
VMX1_PORT=3003

# Kube VMX v2.x hostname + Port
VMX2_HOSTNAME=kube-master.blippar-vision.com
VMX2_PORT=3001

# Kube LTU v7.6.3 hostname + Port
KUBE_LTU_HOSTNAME="http://kube-master.blippar-vision.com"
KUBE_LTU_PORT_ADD="7789"
KUBE_LTU_PORT_FIND="8080"
KUBE_LTU_PORT_ADMIN="8888"
KUBE_LTU_SIMILARITY="http://kubeaddress:$KUBE_LTU_PORT_FIND/api/v2.0/ltuquery/json/SearchImageByUpload"
KUBE_LTU_FINE="http://kubeaddress:$KUBE_LTU_PORT_FIND/api/v2.0/ltuquery/json/FineComparison"
KUBE_LTU_COLORS="http://kubeaddress:$KUBE_LTU_PORT_FIND/api/v2.0/ltuquery/json/GetImageColorsByUpload"
KUBE_LTU_DELETE="http://kubeaddress:$KUBE_LTU_PORT_ADD/api/v2.0/ltumodify/json/DeleteImage"
KUBE_LTU_ADD="http://kubeaddress:$KUBE_LTU_PORT_ADD/api/v2.0/ltumodify/json/AddImage"
KUBE_LTU_STATUS="http://kubeaddress:$KUBE_LTU_PORT_FIND/api/v2.0/ltuquery/json/GetApplicationStatus"
KUBE_LTU_APPLICATIONS="./templates/ltu763-application.json"
#KUBE_LTU_BULK="" # Need a Web Hook

MODEL="kubeFactor"
BACKEND="kubeFactor"

ENDPOINT_MIDDLEWARE="/api/v1/middleware/$BACKEND"
BACKEND_PORT=3003
ASSETS=../kube-assets/
CONTEXT="Mixed visual analysis"

# Default ports and clients for the local version
etcd&
rm -f ./bin/$MIDDLEWARE_SETUP-*

# Will be fck gangsta more dynamic soon ! Chaaaaataaaa !
TEMPLATE=$(cat templates/vmx1.json | base64)
cat ./templates/vmx1.json | jq .
SESSIONS=`curl http://$VMX1_HOSTNAME:$VMX1_PORT/session | jq -r '.data[] .id'`
ENDPOINTS=""
for i in $(echo $SESSIONS | tr " " "\n")
do
  ENDPOINTS+="POST:vmx1://$VMX1_HOSTNAME:$VMX1_PORT/session/$i|"
  # process
done
QUEUE=$(echo -n $ENDPOINTS | sed "s/\(.*\).\{1\}/\1/")
echo $QUEUE

SESSIONS=`curl http://$VMX2_HOSTNAME:$VMX2_PORT/sessions | jq -r '.data[] .id'`
ENDPOINTS=""
for i in $(echo $SESSIONS | tr " " "\n")
do
  ENDPOINTS+="POST:vmx2://$VMX2_HOSTNAME:$VMX2_PORT/sessions/$i|"
  # process
done
QUEUE+="|"
QUEUE=$(echo -n $ENDPOINTS | sed "s/\(.*\).\{1\}/\1/")

etcdctl rm --recursive --dir /vulcand

#ENDPOINTS=""
#SESSIONS=$(cat ./templates/ltu763-application.json | jq -r '.applications[] | "\(.name) \(.database_hostname) \(.is_neural_detection) \(.application_key) \(.type) "')
#for i in $(echo $SESSIONS | tr -s "\n")
#do  
#confarray=($i)
#  echo "$i"
#  echo "POST:ltu763://$KUBE_LTU_SIMILARITY?application_key=$confarray[3]"
#ENDPOINTS+="POST:ltu763://$KUBE_LTU_SIMILARITY?application_key=$confarray[3]|"
# process
#done
#QUEUE+="|"
#QUEUE+=$(echo -n $ENDPOINTS | sed "s/\(.*\).\{1\}/\1/")
#echo $QUEUE | jq .
#exit

# Generate the Mac OSX executable
vbundle init --middleware=github.com/blippar/kube-vproxy/kube-middlewares/kubeDispatcher \
	     --middleware=github.com/blippar/kube-vproxy/kube-middlewares/kubeOCR

VPROXYMAC=$(go build -v -o $MIDDLEWARE_SETUP-osx .)
cp -f patch/fix.go vctl/main.go
pushd vctl/ && go build -o vctl && popd

# Generate the Linux executable
vbundle init --middleware=github.com/blippar/kube-vproxy/kube-middlewares/kubeDispatcher \
             --middleware=github.com/blippar/kube-vproxy/kube-middlewares/kubeOCR

VPROXYLINUX=$(GOOS=linux CGO_ENABLED=0 go build -v -a -installsuffix cgo -o $MIDDLEWARE_SETUP-linux .)
cp -f patch/fix.go vctl/main.go
pushd vctl/ && go build -o vctl && popd
# Move the generate binaries to the bin folder
ls -l
MOVE=$(mv $MIDDLEWARE_SETUP-* ./bin)

BCK_CREATE=$(etcdctl set /vulcand/backends/bck_$MODEL/backend \
"{\"Id\":\"bck_"$MODEL"\",\"Type\":\"http\"}")
echo $BCK_CREATE | jq .
echo "backend output"
etcdctl ls --recursive

SRV_CREATE=$(etcdctl set /vulcand/backends/bck_$MODEL/servers/srv_$MODEL \
"{\"Id\":\"srv_"$MODEL"\",\"URL\":\"http://127.0.0.1:"$BACKEND_PORT"\"}")
echo $SRV_CREATE | jq .
etcdctl ls --recursive

FRONT_CREATE=$(etcdctl set /vulcand/frontends/front_$MODEL/frontend \
"{\"Id\":\"front_"$MODEL"\",\"Type\":\"http\",\"BackendId\": \"bck_"$MODEL"\",\"Route\": \"PathRegexp(\\\"$ENDPOINT_MIDDLEWARE.*\\\")\"}")
echo $FRONT_CREATE | jq .
echo "front-end output"
etcdctl ls --recursive

# Add the middleware
MIDDLEWARE_DISPTACHER=$(etcdctl set /vulcand/frontends/front_$MODEL/middlewares/dispatcher \
"{
    \"Type\": \"kubeDispatcher\",
    \"Middleware\": {
        \"Template\": \""$TEMPLATE"\",
        \"Queue\": \""$QUEUE"\",
	\"ParseScore\": \"vmx2=data.objects[0].score|vmx1=objects[0].score|ltu763=images[0].score\",
        \"ParseMeta\": \"vmx2=data.objects[0].name|vmx1=objects[0].name|ltu763=images[0].keywords\",
        \"ParseBB\": \"vmx2=data.objects[0].bb|vmx1=objects[0].bb|ltu763=images[0].result_info.reference.matchingBox.points\",
        \"MarkerId\": 1234,
        \"BlippId\": 1234,
        \"Context\": \"test\",
        \"Width\": 320,
        \"Height\": 240,
        \"Learn\": 0,
        \"Concurrency\": 50,
        \"Transformation\": \"\",
        \"Nudity\": \"detect\",
        \"Chained\": 0,
        \"MinScore\": 0.2,
        \"Discovery\": \"BATCH\",
        \"ActiveEngines\": \"vmx2,vmx1\",
	\"Debug\": 1
    }
}")
echo $MIDDLEWARE_DISPTACHER | jq .

echo $MIDDLEWARE_OCR_NAME
MIDDLEWARE_OCR=$(etcdctl set /vulcand/frontends/front_kubeFactor/middlewares/Ocr \
"{
    \"Type\": \""$MIDDLEWARE_OCR_NAME"\",
    \"Middleware\": {
        \"MarkerId\": 1234,
        \"BlippId\": 4321,
        \"Context\": \"test Max Factor mentions on labels\",
        \"Width\": 320,
        \"Height\": 240,
        \"Timeout\": 250,
        \"Concurrency\": 50,
        \"Transformation\": \"\",
        \"DetectDarkness\": 0,
        \"Chained\": 1,
	\"OcrPreProcessors\": \"stroke-width-transform=1\",
        \"OcrEngine\": \"engine=tesseract\",
        \"EntitiesExtractor\": \"kube-aida\",
        \"EntitiesDiscovery\": 0,
        \"Debug\": 0
    }
}")

echo "{
    \"Type\": \""$MIDDLEWARE_OCR_NAME"\",
    \"Middleware\": {
        \"MarkerId\": 1234,
        \"BlippId\": 4321,
        \"Context\": \"test Max Factor mentions on labels\",
        \"Width\": 320,
        \"Height\": 240,
        \"Timeout\": 250,
        \"Concurrency\": 50,
        \"Transformation\": \"\",
        \"DetectDarkness\": 0,
        \"Chained\": 0,
        \"OcrPreProcessors\": \"stroke-width-transform=1\",
        \"OcrEngine\": \"engine=tesseract\",
        \"EntitiesExtractor\": \"kube-aida\",
        \"EntitiesDiscovery\": 0,
        \"Debug\": 1
    }
}"

echo $MIDDLEWARE_OCR | jq .
etcdctl ls --recursive

# Create Variable later
echo "Launching the kube proxy: sudo ./bin/$MIDDLEWARE_SETUP-osx -apiInterface=0.0.0.0 -interface=0.0.0.0 -etcd=http://127.0.0.1:2379 -etcdKey=vulcand -port=81 -apiPort=8182"
sudo ./bin/$MIDDLEWARE_SETUP-osx -apiInterface=0.0.0.0 -interface=0.0.0.0 -etcd=http://127.0.0.1:2379 -etcdKey=vulcand -port=81 -apiPort=8182

# Launch a couple of local tests to see the middleware processing some pictures
files="$(find -L "$dir" -type f)"
echo "Count: $(echo -n "$files" | wc -l)"
SESSIONID="KUBE-QUERY-EXPANSION"
echo "$files" | while read file; do
  echo "$file"
  curl -v -X POST -F "file"=@$file -F "region"="us" -F "sessionId"="$SESSIONID" http://localhost:81/api/v1/middleware/queue_maxfactor1
done

# PID information about the proxy and the key/value Store
KUBE_VPROXY_ETCD_PID=$(lsof -P | grep ':2379' | awk '{print $2}')
KUBE_VPROXY_SRV_PID=$(lsof -P | grep ':81' | awk '{print $2}')
echo "To kill the kube etcd2 server, please use kill -9 $KUBE_VPROXY_ETCD_PID"
echo "To kill the kube proxy server, please use kill -9 $KUBE_VPROXY_SRV_PID"

echo "\n"
echo "\n"
