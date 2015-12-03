#!/bin/bash
cd ../build
rm -fR *
cmake -DCMAKE_BUILD_TYPE=Release .. -Wno-dev
make -j12
cd ../bin
kill `ps -ef | grep find_object | grep -v grep | awk '{print $2}'`
cd ./tests
rm -f *.jpg
cd ..
./find_object --config ../config/maxfactor8.ini --objects ../products/logos-samples/logos_forbes --debug &
