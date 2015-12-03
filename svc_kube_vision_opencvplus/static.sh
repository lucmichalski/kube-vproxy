#!/bin/bash
docker stop serverDev
docker rm serverDev
docker run --name severDev -ti --rm -v $(pwd):/src server:dev /bin/bash
