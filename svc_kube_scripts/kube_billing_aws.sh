#!/bin/bash
# Create a static docker container with this script
ls ../kube-billing/*.csv | xargs -I'{}' ./aws-billing --file {} --concurrency 1
