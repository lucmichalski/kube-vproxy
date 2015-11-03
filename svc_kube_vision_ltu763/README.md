# LTU Engine/Server v.7.6.3 - Dockerized, Kubernetes v.1.x deploy

## Introduction: Visual Search

### Images finding images: 
LTU engine is the foundation for visual search: image matching, similarity search, and color search.
Visual search is using one image to find other images. Visual search based upon the content of an image, rather than based on textual information.
Two key technologies of visual search are image description and image search.

### Image description (Indexation): 
The first step toward making an image searchable is to create a descriptor of the image content. LTU engine computes a visual signature for every image 
that describe its visual content in terms of color, shape, texture and many higher order visual features. These descriptors are also called image DNAs.

### Image search: 
Image search is the comparison of one image signature with another, or with millions of other signatures. LTU's proprietary architecture includes a special comparison 
technology by which an image signature can be compared at extremely high speed with other image signatures.

### Main changes:
- Embedding several caffe models (Nudity, Flickr)
- Using an nginx server for dispatching the retrievial or indexation (Stability missing from the version <7.6.3)
- The latest version of the LTU engine available for similarity matching

## Key features of this bootstrap script
- Build LTU 7.6.3 containers with bulk indexation of datasets of pictures
- Bulk load datasets with keywords during the launch on a specific application key
- Simplify the application key management with an interna reverse proxy
- Reduce the number of ports to bind the retrivial or query API endpoints
- Check the health of all LTU's endpoints internally
- Adding new recognition features (Search by Uploads, Search by Colors, Fine Comparison between 2 pictures)
- Getting standard routes to check the health of applications
- Create namespaces for application from a configuration file: eg /us/creative-work/books/ => app_1, /uk/organization/brands/soft_drinks => app_2
- Allow to use query expansion for any visual search (build geographical semantic context)

Tradeoffs managed:
- The license system requires a stable hostname; docker generate a different hostname at each build
- You cannot install LTU 7.6 before the CMD command (Python Env)
- LTU generates random application key; neither Kubernetes or Docker would make the routing easily faisable
- LTU Backend offers several interesting options that we could hacked by creating a cookie .txt file, to simulate a user authentication, then submit some forms with a curl command
- Blippar never add some smart middlewares to convert process images or mitigated concurrent matching queries (Check other repo: kube-middleware)

### Bulk applications creation 
- Create a folder 

## Reverse Proxying of application

### Bulk load large dataset for quick indexation

### Configuration file / How to  ?
Option 1. To build the docker container and run it locally
```
git clone 
cd kube-docker-ltu-v7.6.3
./all.sh
```

Option 2. Run an already built container
```
./run.sh datasets.txt
```
or alternatively
```
docker stop ltu763docker; docker rm ltu763docker; docker run --name=ltu763docker --privileged=true -ti \
                -p 0.0.0.0:1979:1979 \
                -p 0.0.0.0:1980:1980 \
                -p 0.0.0.0:8888:8888 \
		-p -v "$(pwd)/config:/opt/config" \
                -v /opt/logs/features2d/ltu76:/opt/logs \
         lucmichalski/kubevision-ltu76-rest:batch-v1
```

Option 3. Create a replications controller with a service in a Kube-Vision cluster
1. Connect to your laptop (For Installation instruction, please see the following repo)
```
$ ./kube-ltu76.sh
```
Bootstrapping steps:
- Build the docker container locally
- Use the datasets declared in datasets.txt
- Create 10 Applications keys
- Map them with the namespace prefix defined
- Push the container to Blippar's private registry
- Create a Kube-Vision replication controller in the namespace defined
- Create a Kube-Vision service in the namespace defined
- Launch a single replica (Scaling must be doe manually by the Kube owner)
- Display the main status information for the Kube Vision default namespace

## Useful commands for Kube-Vision

1. Check if you have the right version of Kubernetes Client/Kubectl; version shoudl match almost closely to not have breaking changes
```
$ kubectl version --cluster=aws
Client Version: version.Info{Major:"1", Minor:"2+", GitVersion:"v1.2.0-alpha.1", GitCommit:"e3188f6ee7007000c5daf525c8cc32b4c5bf4ba8", GitTreeState:"clean"}
Server Version: version.Info{Major:"1", Minor:"2+", GitVersion:"v1.2.0-alpha.1", GitCommit:"e3188f6ee7007000c5daf525c8cc32b4c5bf4ba8", GitTreeState:"clean"}
```

1. See the latest events logged in the Kube Vision
```
$ kubectl get evenst --cluster=aws
FIRSTSEEN   LASTSEEN   COUNT     NAME      KIND      SUBOBJECT   REASON    SOURCE    MESSAGE
[...]
```

3. Check if you can see the nodes information and to you have selected the right cluster
```
$ kubectl get nodes --cluster=aws
NAME           LABELS                                                     STATUS    AGE
10.0.146.158   kraken-node=node-001,kubernetes.io/hostname=10.0.146.158   Ready     4d
10.0.47.2      kraken-node=autoscaled,kubernetes.io/hostname=10.0.47.2    Ready     4d
10.0.47.3      kraken-node=autoscaled,kubernetes.io/hostname=10.0.47.3    Ready     4d
10.0.47.4      kraken-node=autoscaled,kubernetes.io/hostname=10.0.47.4    Ready     4d
10.0.47.5      kraken-node=autoscaled,kubernetes.io/hostname=10.0.47.5    Ready     4d
```

4. Check the name replica controllers created in the cluster for default namespace
```
$ kubectl --cluster=aws get rc
CONTROLLER                   CONTAINER(S)            IMAGE(S)                                           SELECTOR                         REPLICAS   AGE
cluster-insight-controller   cluster-insight         kubernetes/cluster-insight:v2.0-alpha              app=cluster-insight,version=v2   1          3d
dcolors-rest                 dcolors-rest            lucmichalski/cloudcv-dominantcolors:kube           name=dcolors-rest                10         3d
framework                    framework               quay.io/samsung_ag/trogdor-framework:latest        name=framework                   10         4d
grafana-v1                   grafana                 quay.io/samsung_ag/grafana:latest                  k8s-app=Grafana,version=v1       1          4d
influxdb-v1                  influxdb                quay.io/samsung_ag/influxdb:latest                 k8s-app=InfluxDB,version=v1      1          4d
libccv-rest                  libccv-rest             lucmichalski/libccv-restapi                        name=libccv-rest                 10         3d
load-generator-master        load-generator-master   quay.io/samsung_ag/trogdor-load-generator:latest   name=load-generator-master       1          4d
load-generator-slave         load-generator-slave    quay.io/samsung_ag/trogdor-load-generator:latest   name=load-generator-slave        5          4d
podpincher                   podpincher              quay.io/samsung_ag/podpincher:latest               name=podpincher                  1          4d
prometheus                   promdash                quay.io/samsung_ag/promdash:latest                 name=prometheus                  1          4d
                             prometheus              quay.io/samsung_ag/prometheus:latest
                             pushgateway             jayunit100/prompush:0.2.0
```

5. Check theservices created for the kube-system namespace (Display all internal addons to Kube-Vision).
```
$ kubectl get svc --cluster=aws --namespace=kube-system
NAME              CLUSTER_IP      EXTERNAL_IP   PORT(S)         SELECTOR                         AGE
cluster-insight   10.100.19.236   <none>        5555/TCP        app=cluster-insight,version=v2   3d
kube-dns          10.100.0.10     <none>        53/UDP,53/TCP   k8s-app=kube-dns                 4d
kube-ui           10.100.233.77   <none>        80/TCP          k8s-app=kube-ui                  3d
```
6. Check all the publicly exposed administration modules
```
$ kubectl cluster-info --cluster=aws
Kubernetes master is running at http://kube-master.blippar-vision.com:8080
KubeDNS is running at http://kube-master.blippar-vision.com:8080/api/v1/proxy/namespaces/kube-system/services/kube-dns
KubeUI is running at http://kube-master.blippar-vision.com:8080/api/v1/proxy/namespaces/kube-system/services/kube-ui
```

7. Check that all the pods already running are not flagging abmormal restarts and unhealthy statuses
```
$ kubectl get pods --cluster=aws
NAME                               READY     STATUS    RESTARTS   AGE
cluster-insight-controller-e4ve5   1/1       Running   0          3d
dcolors-rest-1yh9f                 1/1       Running   0          3d
dcolors-rest-6vnns                 1/1       Running   0          3d
dcolors-rest-8zoxd                 1/1       Running   0          3d
dcolors-rest-dbfdm                 1/1       Running   0          3d
dcolors-rest-h4tqo                 1/1       Running   0          3d
dcolors-rest-hznpq                 1/1       Running   0          3d
dcolors-rest-qk11q                 1/1       Running   0          3d
dcolors-rest-riy7t                 1/1       Running   0          3d
dcolors-rest-td33q                 1/1       Running   0          3d
dcolors-rest-xbi7g                 1/1       Running   0          3d
framework-530wx                    1/1       Running   0          4d
framework-dic3n                    1/1       Running   0          4d
framework-jxijq                    1/1       Running   0          4d
framework-k20go                    1/1       Running   0          4d
framework-l1dva                    1/1       Running   0          4d
framework-lh6ff                    1/1       Running   0          4d
framework-p3pxh                    1/1       Running   0          4d
framework-vqrrw                    1/1       Running   0          4d
framework-wfg8u                    1/1       Running   0          4d
framework-zcpsg                    1/1       Running   0          4d
grafana-v1-57vn8                   1/1       Running   0          4d
influxdb-v1-dpxnk                  1/1       Running   0          4d
libccv-rest-2im8f                  1/1       Running   0          3d
libccv-rest-4lvfa                  1/1       Running   0          3d
libccv-rest-9mqva                  1/1       Running   0          3d
libccv-rest-arc1q                  1/1       Running   0          3d
libccv-rest-dkn9r                  1/1       Running   0          3d
libccv-rest-e6fm9                  1/1       Running   0          3d
libccv-rest-hycr2                  1/1       Running   0          3d
libccv-rest-k6i1w                  1/1       Running   0          3d
libccv-rest-uaa5m                  1/1       Running   0          3d
libccv-rest-wj2io                  1/1       Running   0          3d
load-generator-master-hfmvu        1/1       Running   0          4d
load-generator-slave-4rv2g         1/1       Running   0          4d
load-generator-slave-k3iwu         1/1       Running   0          4d
load-generator-slave-ltijx         1/1       Running   0          4d
load-generator-slave-nx3x8         1/1       Running   0          4d
load-generator-slave-x12ea         1/1       Running   0          4d
podpincher-cz46u                   1/1       Running   0          4d
prometheus-rbq1m                   3/3       Running   0          4d
```
