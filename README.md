# Kube-VProxy Middlewares (Summary)

## Query Expansion for VMX v1.x and VMX 2.x

Features:
--------

* Uses Etcd as a configuration backend.
* API and command line tool.
* Pluggable middleware for nesting results from Vision.ai VMX 1.x and VMX 2.x.
* Resizing multi-part pictures on the fly 
* Converting multi-part to base64 string
* Use specific JSON templates payloads per model
* Dynamic replacement of variables per model configuration
* Support for canary deploys, realtime metrics and resiliency.
* Benchmark tests (Plots, Reports)
* Un-learning mode for false/positive matches (Optional but fck important)
* Chains of different middlewares (Semantic enrichment, Knowledge Graph)

To come very soon:
--------

* Web UI for editing templates 
* Full text search engine
* Hierarchical trees per visual verticals
* Learn new visual entities on the fly
* Kubenertes replication controller and service template

## Global Query Expansion

To come very Soon:
--------
* Chained middlewares
	* Category Recognition
	* Vocabulary Interface
        * Visual Projection into a Text Space
        * Instance Matching (Fine grained detection)
	        * Logo recognition (less than 5ms)
	        * Face recognition with RCNN
	        * Features 2D
* Geographic visual cache clusters
