# Kubernetes Namespaces

## Purpose
This directory contains the Namespace definitions needed at a gloal level for a Kubernetes cluster.

This directory needs to be included and "kubectl create -f" first, before any other services are created.

## File Name Format
Please include -ns on these files to indicate they are Namespace definitions.  e.g. <whatere>-ns.yaml

## List
* kube-system - used by:
  * skydns (kube-dns)
* 
