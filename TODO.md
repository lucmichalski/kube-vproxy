# Todo

This Visual Proxy will be a middleware between pictures sent from a mobile device to extract and match some content registered in a database through any chain of visual mining.

## Make that a middleware can write a JSON Response without connecting to the backend and follow the chain define for the frontends

### Current code:
- https://github.com/lucmichalski/kube-vproxy/blob/master/kube-query-expansion/Godeps/_workspace/src/github.com/blippar/kube-vproxy-plugins/kube-middlewares/kubeDispatcher/kubeDispatcher.go#L373
- https://github.com/lucmichalski/kube-vproxy/blob/master/kube-query-expansion/Godeps/_workspace/src/github.com/blippar/kube-vproxy-plugins/kube-middlewares/kubeOCR/kubeOCR.go#L337

### Goals:
- Circuit breakers
- Stop the processing if some blocking insights are detected
- Define dynamic visual mining chains

Results found:
```
[{'vmx1':
    {
        "Results":
            [{
                "ID": int,
                "Score": "float64",
                "Keywords": ["string"]
             },{
                "ID": int,
                "Score": "float64",
                "Keywords": ["string"]
             },{
                "ID": int,
                "Score": "float64",
                "Keywords": ["string"]
             },
                ],
                "Status": {
                        "Code": 0
        }
}, {'vmx2':
    {
        "Results":
            [{
                "ID": int,
                "Score": "float64",
                "Keywords": ["string"]
             },{
                "ID": int,
                "Score": "float64",
                "Keywords": ["string"] // Any OCR input is added to keywords
             }],
        "Status": {
            "Code": 0
        }
}]
```
## Nothing found:
```
{ "Results": [],
  "Status": {
       "Code": 400
  }
}
```
## Batch requests with several strategies

### Why ? 
- Some sub-routines will have a longer output time
	- VMX1 (500ms), VMX2 (250ms) 1 scene to X models 
		- Need to create a context
	- LTU 7.6.3 = 1 scene compared to 500k pictures DNAs
- Some sub-routines will requests to have a larger scope of models to query in parallel
	- VMX1, VMX2: 
		- 1 model = 1 object
		- 1 model per orientation (portrait, landscape)
	- LTU 7.6.3 = 500k pictures
		- Similarity ranking
- Some sub-routines need to be grouped by priority, popularity 
	- Problems of large datasets in computer vision
	- Lifetime of visual patterns
- Some image comparison will require to be projected into a Text Space
	- Create a context to the processing
	- Start to work on predictive modeling of the projection in a text space

Eg of text space: http://openvoc.berkeleyvision.org/Open-Vocabulary_Object_Retrieval_RSS-2014-Poster.pdf

### How I will do that ?
- Create frontends in VProxy, define a chaine of middlewares
- I will use Kubernetes as the system load balancing my services (and not this proxy)
- I will create a small graph of objects and concepts linked together

### Eg Routes:
```
api/v1/vision/ltuengine/7.6.3/similarity/world/orginization/brands/logopedia.org
api/v1/vision/ltuengine/7.6.3/similarity/world/creative/vod/movies/tv
api/v1/vision/ltuengine/7.6.3/similarity/world/creative/books/goodreads.com
api/v1/vision/ltuengine/7.6.3/similarity/person/comedian/english
api/v1/vision/ltuengine/7.6.3/similarity/person/celebrities/cross-invariant-age
api/v1/vision/ltuengine/7.6.3/similarity/world/creative/art/gb/london
api/v1/vision/ltuengine/7.6.3/similarity/usa/west/cache/1
api/v1/vision/ltuengine/7.6.3/similarity/usa/east/cache/2
api/v1/vision/ltuengine/7.6.3/similarity/europe/cache/3
api/v1/vision/ltuengine/7.6.3/similarity/japan/cache/4
api/v1/vision/ltuengine/7.6.3/similarity/blippar/connect/default
api/v1/vision/ltuengine/7.6.3/similarity/blippar/hub/default
api/v1/vision/ltuengine/7.6.3/similarity/americas/AI/Anguilla
api/v1/vision/ltuengine/7.6.3/similarity/americas/AR/Argentina
api/v1/vision/ltuengine/7.6.3/similarity/americas/AW/Aruba
```

Ideas fro playing with the text space:
- Modern text indexing in go (Golang)
	- https://github.com/blevesearch/bleve
- Graph, topological sort (Golang)
	- https://github.com/gyuho/learn/tree/master/doc/go_graph_topological_sort
- Cayley is an open-source graph inspired by the graph database behind  Freebase and Google's Knowledge Graph.  (Golang)
	- https://github.com/google/cayley
	- Small example: https://github.com/google/cayley/blob/master/data/testdata.nq
- Binary Search Tree (Golang)
	- https://github.com/gyuho/learn/tree/master/doc/go_b_tree#btree-insert
- Heap data structure (Golang)
	- https://github.com/gyuho/learn/tree/master/doc/go_heap_priority_queue
- Distributed Search (C++,Nano Messaging)
	- https://github.com/daniel-j-h/DistributedSearch

### Current code:
- Only one strategy, batching the requests whatever the popularity of an endpoint
- https://github.com/lucmichalski/kube-vproxy/blob/master/kube-query-expansion/Godeps/_workspace/src/github.com/lepidosteus/golang-http-batch/batch/batch.go
- https://github.com/lucmichalski/kube-vproxy/blob/master/kube-query-expansion/Godeps/_workspace/src/github.com/blippar/kube-vproxy-plugins/kube-middlewares/kubeDispatcher/kubeDispatcher.go#L294

### Goals:
- Dynamic rebalancing of frontends
- Optimize the performances of the continious flow of media inputs 




