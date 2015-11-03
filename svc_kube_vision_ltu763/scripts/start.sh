#!/bin/sh

# Luc Michalski - 2015
# It was a nightmare to get a stable LTU environemnt dockerized then integrated into Kubernetes
# 11 October 2015 / New York

# Goals:
# - Get LTU environement running without any sub-services corrupted (Postgresql)
# - Create a custom configuration file for LTU
# - Add some variables at the build up in order to bulk upload some datasets (Logos, Arts)
# - Just have to launch a scale function to get the Vision Kube more QPS

# To do:
# - Block the internal clock of the server fo fake it to freeze the license system
# - Get a faster start
# - Script to map LTU's application and Traefik reverse proxy

# Luc Michalski - 2015
# It was a nightmare to get a stable LTU environemnt dockerized then integrated into Kubernetes
# 11 October 2015 / New York

# Goals:
# - Get LTU environement running without any sub-services corrupted (Postgresql)
# - Create a custom configuration file for LTU
# - Add some variables at the build up in order to bulk upload some datasets (Logos, Arts)
# - Just have to launch a scale function to get the Vision Kube more QPS

# To do:
# - Block the internal clock of the server fo fake it to freeze the license system
# - Get a faster start
# - Script to map LTU's application and Traefik reverse proxy
cd /etc/yum.repos.d/
wget http://download.opensuse.org/repositories/home:/tange/CentOS_CentOS-6/home:tange.repo
yum install -y jq parallel zip runuser logstash-forwarder
cd /opt
test -n "$BUCKET_NAME" || die "Please set BUCKET_NAME environment variable"
test -n "$ACCESS_KEY" -a -n "$SECRET_KEY" || die "Please set ACCESS_KEY and SECRET_KEY environment variables"

echo ""
echo "==================== S3 Bucket Syncing process"
echo Executing in $(pwd)
echo "Access Key: $ACCESS_KEY"
echo "Secret Key: $SECRET_KEY"
echo "Bucket Name: ${BUCKET_NAME}"
echo "Path on Bucket: s3://${BUCKET_NAME}/datasets/models/datasets/utils/ltuengine76-core/"

# Replace the old legacy hosts hash from docker
sed -i -e "s/0214bf566d99/ltu76/g" /opt/ltu-engine-7.6.3/licence.lic
echo "Check the LTU License ============="

cat /opt/ltu-engine-7.6.3/licence.lic
date --set "17 Feb 2015 15:00:00"
/check_license /opt/ltu-engine-7.6.3/licence.lic
echo ""

echo "HOST ALIASING ============="
echo "create an alias for the host ltu76, it solves the LTU's license host consistency requirement"
/usr/local/bin/mungehosts -l ltu76
echo "altered the /etc/hosts inside the Docker Container"

cd /
/usr/bin/etcd&

sleep 5

/usr/bin/vulcand -interface="0.0.0.0" -etcd="http://127.0.0.1:4001" -port=80 -apiPort=8182&

echo "Install LTU 7.63 ============="
cd /opt/ltu-engine-7.6.3 && ls -l && yes|./install.sh /opt/ltuengine76; echo ok

# Modify LTU 7.6 configuration (Kima's, weki's numbers)
echo "Replace the full lutengine specs by our custom values"
rm -f /opt/ltuengine76/run/cache/config/ltuengine.full.spec
cp /opt/ltuengine.full.spec /opt/ltuengine76/run/cache/config/ltuengine.full.spec
# chmod +x /opt/ltuengine76/core/bin/ltusaas-generate-config-files
sed -i -e "s/frontoffice_max_post_size_in_mb = 1000/frontoffice_max_post_size_in_mb = 25000/g" /opt/ltuengine76/run/cache/config/frontoffice.cfg
sed -i -e "s/openmp_num_threads = 1/openmp_num_threads = 14/g" /opt/ltuengine76/run/cache/config/processor.cfg
sed -i -e "s/openmp_num_threads = 1/openmp_num_threads = 14/g" /opt/ltuengine76/run/cache/config/app_worker.cfg
sed -i -e "s/openmp_num_threads = 1/openmp_num_threads = 14/g" /opt/ltuengine76/run/cache/config/weki.cfg
sed -i -e "s/openmp_num_threads = 1/openmp_num_threads = 14/g" /opt/ltuengine76/run/cache/config/frontoffice.cfg
sed -i -e "s/openmp_num_threads = 1/openmp_num_threads = 14/g" /opt/ltuengine76/run/cache/config/admin_worker.cfg
sed -i -e "s/openmp_num_threads = 1/openmp_num_threads = 14/g" /opt/ltuengine76/run/cache/config/manager.cfg
sed -i -e "s/openmp_num_threads = 1/openmp_num_threads = 14/g" /opt/ltuengine76/run/cache/config/kima.global.cfg

echo "Apply the new configuration to the LTU 7.63 environement ============="

cp /opt/ltuengine.full.spec /opt/ltuengine76/run/cache/config/ltuengine.full.spec
HOSTNAME=$(hostname -f)
echo "Container hostname is $HOSTNAME"
find /opt/ltuengine76/ltu/env/run/cache/config -type f -exec sed -i "s/$HOSTNAME/ltu76/g" {} \;

sed -i -e "s/$HOSTNAME/ltu76/g" /opt/ltuengine76/run/cache/config/ltuengine.full.spec

runuser -l ltu -c 'psql -U ltu -p 7791 saas_si -a -f /opt/vpc_security.sql'

service ltud restart all
rm -fR /opt/ltu-engine-7.6.3/

chmod -Rf 755 /opt/ltuengine76/

cd /opt
#ln -s /opt/ltuengine76/logs logs
ls -l logs/

echo "============================="
echo "Current configuration file for Wekis and Kimas"
cat /opt/ltuengine76/config/ltuengine.spec

echo "============================="
echo "Current full configuration file in cache"
#cat /opt/ltuengine76/run/cache/config/ltuengine.full.spec

#  Display some quick informations about the available endpoints
echo "============================="
echo "Proxying on the port 1979"
echo "Web UI available on the port 1980"
echo "============================="
echo "Other quick notes:"
echo "For test purpose, we exposed the LTU 7.6 backend because"
echo "- need to create empty applications"
echo "- need to increase the POST Vaiable size"
echo "- need to change the networking security parameters for bulk uploads or retrivial queries"
echo "============================="

echo Executing in $(pwd)
echo "Access Key: $ACCESS_KEY"
echo "Secret Key: $SECRET_KEY"
echo "Bucket Name: ${BUCKET_NAME}"
echo "Path on Bucket: s3://${BUCKET_NAME}/datasets/models/datasets/utils/ltuengine76-core/"
cd /opt

echo ""
echo "===================="

cd /opt
echo ""
echo "===================="
echo "Sync to get the installation files and dependencies"

curl -L -c /blippar.txt -X POST -F login=sadmin -F password=sadmin http://localhost:8888/login_handler

create_endpoints(){

echo "Parameters to be processed: $1 $2 $3 $4 $5"

app_key=$1
endpoint=$2
port=$4
echo $application_key
link=$3

BCK_CREATE="curl -s -X POST -H \"Content-Type: application/json\" http://127.0.0.1:8182/v2/backends -d '{\"Backend\":{\"Id\":\"bck_"$app_key"\",\"Type\":\"http\"}}'"
#echo $BCK_CREATE
OUTPUT=$(eval $BCK_CREATE)
echo "backend output"
echo $OUTPUT | jq .

SRV_CREATE="curl -s -X POST -H \"Content-Type: application/json\" http://127.0.0.1:8182/v2/backends/bck_$app_key/servers -d '{\"Server\":{\"Id\":\"srv_"$app_key"\",\"URL\":\"http://127.0.0.1:"$port"\"}}'"
OUTPUT=$(eval $SRV_CREATE)
#echo $SRV_CREATE
echo "server output"
echo $OUTPUT | jq .

FRONT_CREATE="curl -s -X POST -H \"Content-Type: application/json\" http://127.0.0.1:8182/v2/frontends -d '{\"Frontend\": {\"Id\":\"front_"$app_key"\",\"Type\":\"http\",\"BackendId\": \"bck_"$app_key"\",\"Route\": \"PathRegexp(\\\"/api/v1/vision/ltuengine/7.6.3"$link".*\\\")\"}}'"
#echo $FRONT_CREATE
OUTPUT=$(eval $FRONT_CREATE)
echo "front-end output"
echo $OUTPUT | jq .

echo "/api/v1/vision/ltuengine/7.6.3$link" >> /opt/proxy_endpoints_registry.txt

MIDDLE_CREATE="curl -s -X POST -H \"Content-Type: application/json\" http://127.0.0.1:8182/v2/frontends/front_"$app_key"/middlewares\
                   -d '{\"Middleware\": {
                       \"Id\":\"front_"$app_key"\",
                       \"Priority\":1,
                       \"Type\":\"rewrite\",
                       \"Middleware\":{
                          \"Regexp\":\"/api/v1/vision/ltuengine/7.6.3"$link"(.*)\",
                          \"Replacement\":\""$endpoint"\",
                          \"RewriteBody\":false,
                          \"Redirect\":false}}}'"
#echo $MIDDLE_CREATE
OUTPUT=$(eval $MIDDLE_CREATE)
echo "middleware output"
echo $OUTPUT | jq .
echo "Route created: /api/v1/vision/ltuengine/7.6.3$link"

#etcdctl ls --recursive

}

# need to fix variable names
while IFS=, read col1 col2 col3 col4 col5 col6
do
    echo "Dataset to bulk load: $col1|$col2|$col3|$col4|$col5|$col6"
    
	if [ -z "$col2" ]
	then
		echo "nothing to cross-load from our bucket"
	else
	    	s3cmd --config=/.s3cfg --access_key="$ACCESS_KEY" --secret_key="$SECRET_KEY" sync s3://${BUCKET_NAME}$col2 /opt/datasets
		echo $col3;
 		mkdir -p /opt/data/$col1
    		unzip -d /opt/data/$col1 /opt/datasets/$col4/$col3
    		rm /opt/datasets/$col4/$col3
    		echo "Zip file path: /opt/datasets/$col4/$col3"
    		ls -l /opt/data
	fi

        if [ -z "$col1" ]
        then
                echo "nothing to cross-load from our bucket"
	else
	        curl -b /blippar.txt -X POST -F site=chiwa -F came_from="/application/add" -F name="$col1" -F template="Mobile Matching" -F comment="$col1" http://localhost:8888/applications/add_action
	        curl -s -b /blippar.txt http://localhost:8888/applications/get_applications_status?_=1444752703264
		application_key=`curl -s -b /blippar.txt http://localhost:8888/applications/get_applications_status?_=1444752703264 | jq -r ".applications[] | select(.name==\""$col1"\") .application_key"`
	        echo "Application key generated: $application_key"
	        echo ""
	        echo "The generated application key is: $application_key"
	fi

	if [ -z "$col2" ]
        then
                echo "nothing to re-pack"
	else
		echo "We limit the number of files to 500,000 per application"
		echo "Zipping files...."
		find /opt/data/$col1/* -name '*,*' -type d | while read f; do mv "$f" "${f//,/|}"; done   
		rm -f /opt/data/*.zip; cd /opt/data/; find ./$col1/*  -regex ".*\.\(jpg\|png\|jpeg\)"  -print $1 | head -500000 | zip -r /opt/data/dataset_$col1.zip -@
		echo "||||||||||||||||||||||||||||"
    		echo "Bulk importing the LTU Application dedicated to this dataset:"
    		echo ""
		curl -v -b /blippar.txt -X POST -F zip_file=@/opt/data/dataset_$col1.zip -F report_name=$col1 "http://localhost:8888/content/batch_add_images/$application_key"
		echo "||||||||||||||||||||||||||||"
		# removing the original dataset
		echo "removing the original dataset"
    		ls -l /opt/datasets
    		rm -fR /opt/datasets/$col4/$col3
    		ls -l /opt/datasets
	fi

              if [ -z "$col6" ]; then
                     	col6=$(echo $col1 | sed 's/_/\//g')
              fi

		col6=$(echo $col6 | sed 's/_/\//g')

              # Search by Multi-Part/Similarity
               	create_endpoints $application_key /api/v2.0/ltuquery/json/SearchImageByUpload?application_key=$application_key /similarity/$col6 8080

               	# Search by Multi-Part/Colors
                create_endpoints $application_key /api/v2.0/ltuquery/json/GetImageColorsByUpload?application_key=$application_key /colors/$col6 8080

                # Fine Comparison Multi-part
                create_endpoints $application_key /api/v2.0/ltuquery/json/FineComparison?application_key=$application_key /fine/$col6 8080

                # Add one single marker to the application
                create_endpoints $application_key /api/v2.0/ltumodify/json/AddImage?application_key=$application_key /add/$col6 7789

                # Check the status of the application
                create_endpoints $application_key /api/v2.0/ltuquery/json/GetApplicationStatus?application_key=$application_key /status/$col6 8080

done < /datasets.txt

cat $TEMP_BACKEND_PATH/$CHECK_TIME/bck_*.toml >> /opt/traefik/backends_tmp.toml
cat $TEMP_BACKEND_PATH/$CHECK_TIME/fo_*.toml >> /opt/traefik/frontends_tmp.toml
cat /opt/traefik/backends_tmp.toml /opt/traefik/frontends_tmp.toml >> /opt/traefik/new_rules.toml
rm -f /opt/traefik/backends_tmp.toml
rm -f /opt/traefik/frontends_tmp.toml
cp -Rf /opt/traefik/new_rules.toml /opt/rules_test.toml
chmod -f 755 /opt/rules.toml
cat /traefik.toml
cat /rules.toml

# removing temporary sub-datasets
echo "removing temporary sub-datasets"
rm -Rf /opt/data/*

ls -l /opt

mkdir -p $GOPATH/src/github.com/bketelsen
cd $GOPATH/src/github.com/bketelsen
git clone https://github.com/jordic/captainhook.git
cd captainhook
go build .

# Let's start the groove armada
echo ""
echo "START CONTAINER ============="
echo "Starting the internal reverse proxy..."

/traefik_d /traefik.toml
