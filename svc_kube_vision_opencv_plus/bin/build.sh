#!/bin/bash
cd ../build
rm -fR ./*
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j8
cd ../bin
./kubevision_logos
