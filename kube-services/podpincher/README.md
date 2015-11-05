# podpincher

A web UI visualising pod - to - host distribution in a kraken cluster.

## Compatibility

Kubernetes API v1 (will not work with v1beta3)

## Setup
### local cluster:
```sh
kraken local up
kubectl --cluster=local create -f other
```
Then wait for the pods to exit Pending state and open http://172.16.1.103:30977 in your browser
### aws cluster

First make sure your aws settings.yaml has the elastic load balancer configured correctly:
```sh
elb:
    name: your_elb_name
    dns_name: something.kubeme.io
    listeners:
      - elb_port: 80
        forwarding_to: 30061
        protocol: HTTP
      - elb_port: 8080                # add this section to the listeners array
        forwarding_to: 30977          # add this section to the listeners array
        protocol: HTTP                # add this section to the listeners array
    healthy_threshold: 2
    unhealthy_threshold: 3
    timeout: 5
    interval: 30
    heathcheck_port: 30977
```
then:
```sh
kraken aws up
kubectl --cluster=aws create -f other
```

Then wait for the pods to exit Pending state and open http://something.kubeme.io:8080 in your browser

### nuc cluster:
```sh
kraken local up
kubectl --cluster=nuc create -f other
```
Then wait for the pods to exit Pending state and open http://ip of a node:30977 in your browser
