#!/bin/bash
#openssl req -x509  -batch -nodes -newkey rsa:2048 \
#-keyout svc_kube_metrics_logstash/conf/logstash-forwarder.key \
#-out svc_kube_metrics_logstash/conf/logstash-forwarder.crt \
#-subj /CN=svc_kube_metrics_logstash
#cp -f ./svc_kube_metrics_logstash/conf/logstash-forwarder.crt ./svc_kube_metrics_forwarder/ssl/logstash-forwarder.crt
#cp -f ./svc_kube_metrics_logstash/conf/logstash-forwarder.key ./svc_kube_metrics_forwarder/ssl/logstash-forwarder.key
docker rm $(docker ps -a -q)
docker rmi $(docker images | grep "^<none>" | awk '{print $3}')
docker-compose -f cluster_kubeVision.docker-compose.yml stop
docker-compose -f cluster_kubeVision.docker-compose.yml rm -f svc_kube_discovery_vproxy_1
docker-compose -f cluster_kubeVision.docker-compose.yml build
docker-compose -f cluster_kubeVision.docker-compose.yml up -d

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
KUBE_LTU_APPLICATIONS="./kube-query-expansion/templates/ltu763-application.json"
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
TEMPLATE=$(cat ./kube-query-expansion/templates/vmx1.json | base64)
cat ./kube-query-expansion/templates/vmx1.json | jq .
SESSIONS=`curl http://$VMX1_HOSTNAME:$VMX1_PORT/session | jq -r '.data[] .id'`
ENDPOINTS=""
for i in $(echo $SESSIONS | tr " " "\n")
do
  ENDPOINTS+="POST:vmx1://$VMX1_HOSTNAME:$VMX1_PORT/session/$i|"
  # process
done
QUEUE=$(echo -n $ENDPOINTS | sed "s/\(.*\).\{1\}/\1/")


SESSIONS=`curl http://$VMX2_HOSTNAME:$VMX2_PORT/sessions | jq -r '.data[] .id'`
ENDPOINTS=""
for i in $(echo $SESSIONS | tr " " "\n")
do
  ENDPOINTS+="POST:vmx2://$VMX2_HOSTNAME:$VMX2_PORT/sessions/$i|"
  # process
done
QUEUE+="|"
QUEUE=$(echo -n $ENDPOINTS | sed "s/\(.*\).\{1\}/\1/")

curl -X POST -H "Content-Type: application/json" -d "{\"Backend\": {\"Id\":\"bck_"$MODEL"\",\"Type\":\"http\"}}" http://192.168.99.100:8182/v2/backends | jq .

curl -X POST -H "Content-Type: application/json" -d "{\"Server\": {\"Id\":\"srv_"$MODEL"\",\"URL\":\"http://192.168.99.100:81\"}}" "http://192.168.99.100:8182/v2/backends/bck_$MODEL/servers"  | jq .

curl -X POST -H "Content-Type: application/json" -d "{\"Frontend\": {\"Id\":\"front_"$MODEL"\",\"Type\":\"http\",\"BackendId\": \"bck_"$MODEL"\",\"Route\": \"PathRegexp(\\\"$ENDPOINT_MIDDLEWARE.*\\\")\"}}" http://192.168.99.100:8182/v2/frontends  | jq .

curl -X POST -H "Content-Type: application/json" http://192.168.99.100:8182/v2/frontends/front_kubeFactor/middlewares\
	-d "{\"Middleware\": {
         \"Id\": \"front_kubeFactor\",
         \"Priority\":1,
	     \"Type\": \"kubeDispatcher\",
         \"Middleware\":{
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
	        \"Chained\": 1,
	        \"MinScore\": 0,
	        \"Discovery\": \"BATCH\",
	        \"ActiveEngines\": \"vmx2,vmx1\",
			\"Debug\": 1
        }
    }
}" | jq .


 curl -X POST -H "Content-Type: application/json" http://192.168.99.100:8182/v2/frontends/front_kubeFactor/middlewares \
     -d '{"Middleware": {
         "Id": "front_kubeFactor",
         "Priority":2,
	     "Type": "kubeOCR",
         "Middleware":{
	        "MarkerId": 1234,
	        "BlippId": 4321,
	        "Context": "test Max Factor mentions on labels",
	        "Width": 320,
	        "Height": 240,
	        "Timeout": 250,
	        "Concurrency": 50,
	        "Transformation": "",
	        "DetectDarkness": 0,
	        "Chained": 0,
			"OcrPreProcessors": "stroke-width-transform=1",
	        "OcrEngine": "engine=tesseract",
	        "EntitiesExtractor": "kube-aida",
	        "EntitiesDiscovery": 0,
	        "Debug": 1
        }
    }
}'  | jq .

#curl -XPUT localhost:9200/_template/aws_billing -d "`cat ./kube-templates/svc_kube_aws-billing-es-template.json`"
#docker-compose -f cluster_kubeVision.docker-compose.yml logs
files="$(find -L "./kube-assets/ocr_text/" -type f)"
echo "Count: $(echo -n "$files" | wc -l)"
SESSIONID="KUBE-QUERY-EXPANSION"
echo "$files" | while read file; do
  echo "$file"
  ./upload-local-file.sh $file
  curl -v -X POST -F "file"=@$file -F "region"="us" -F "sessionId"="$SESSIONID" http://192.168.99.100:81/api/v1/middleware/kubeFactor
done
