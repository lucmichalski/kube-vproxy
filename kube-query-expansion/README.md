# Build the middleware

## Automated build
```

```

## Manually

### Create a folder in the $GOPATH and clone the github repo
```
$ mkdir $GOPATH/src/github.com/layardev && cd $GOPATH/src/github.com/layardev && git clone http://github.com/layardev/kube-vproxy-middlewares
```

### Install the vctl and vbundle cli-tools
```
$ go get github.com/vulcand/vulcand/vctl
$ go get github.com/vulcand/vulcand/vbundle
```

### Create a folder in your GOPATH environment that will be used for your version of Vulcand with the new middleware.
```
$ mkdir $GOPATH/src/github.com/kube-vproxy-middlewares
```

### Access the newly created folder 
