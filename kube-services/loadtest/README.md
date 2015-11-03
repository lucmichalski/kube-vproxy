# trogdor

## Running:

## local cluster
Adjust number of nodes in your local settings.yaml

Fire up local kraken cluster (you'll need to clone kraken repo)

   kraken local up

Create benchmark controllers and services:

    kubectl create --cluster=local -f other

Now you can go the http://172.16.1.103:30340/ and run a test.

## NUC cluster

Fire up NUC cluster

Create benchmark controllers and services:

    kubectl create --cluster=nuc -f nuc

Now you can go the http://a node ip:30340/ and run a test.

## aws cluster

Adjust number of nodes in your aws settings.yaml

Update your aws settings.yaml file. Add

    elb:                                                       
       name: name_of_your_elb
       dns_name: your_nickname.kubeme.io                                                   
       balancer_port: 80                                       
       instance_port: 30061                                      
       healthy_threshold: 2                                     
       unhealthy_threshold: 3                                   
       timeout: 5                                               
       interval: 30                                             
       target_port: 30061    

to aws section of the config

make sure that 

    hostedZoneId:
    
value is set.

Fire up aws kraken cluster (you'll need to clone kraken repo)

    kraken aws up

Create benchmark controllers and services:

    kubectl create --cluster=aws -f other
    
After all pods become ready, Locust load generator UI will be usable. Now you can go the http://your_nickname.kubeme.io and run a test.

## scaling (on aws)
Resize the number of load generator slaves while the test is running. Observe:

    kub scale --cluster=aws --replicas=300 rc load-generator-slave

You should see numbr of slaves at http://your_nickname.kubeme.io go up shortly

Resize the number of frameworks while the test is running. Observe:

    kub scale --cluster=aws --replicas=50 rc framework
