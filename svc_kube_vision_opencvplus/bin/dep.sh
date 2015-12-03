#!/bin/bash
DEPENDENCIES_PATH="/Users/lucmichalski/.go/src/github.com/blippar/kube-luc/svc_kube_vision_opencvplus/dependencies/"
ROOT_PATH="/Users/lucmichalski/.go/src/github.com/blippar/kube-luc/svc_kube_vision_opencvplus/"

# Create and enter the dependencies folder
cd $ROOT_PATH
mkdir -p $DEPENDENCIES_PATH
cd $DEPENDENCIES_PATH

# Cleaning old dependencies
apt-get autoremove

# Clone RapidJson
git clone https://github.com/miloyip/rapidjson
cd rapidjson
git submodule update --init
mkdir build
cd build
cmake ..
make -j8
make install

# Clone the repo for Bond

# Bond is an open source, cross-platform framework for working with schematized data.
# It supports cross-language serialization/deserialization and powerful generic mechanisms for efficiently manipulating data.
# Bond is broadly used at Microsoft in high scale services.
cd $DEPENDENCIES_PATH
git clone --recursive https://github.com/Microsoft/bond.git
cd bond

# Install dependencies
apt-get install -y \
    clang \
    cmake \
    libtool \
    imagemagick \
    libbz2-dev \
    libc6-dev \
    libcurl4-openssl-dev \
    libevent-dev \
    libffi-dev \
    libglib2.0-dev \
    libjpeg-dev \
    liblzma-dev \
    libmagickcore-dev \
    libmagickwand-dev \
    libyaml-dev \
    libwebp-dev \
    zlib1g-dev \
    ghc \
    cabal-install \
    libboost-dev \
    libboost-thread-dev

# Install Cabal
cabal update
cabal install cabal-install

# Compile bond serialization
mkdir -p build
cd build
cmake ..
make -j8
make install

# Build all the C++ and Python tests and examples
apt-get install \
    python2.7-dev \
    libboost-date-time-dev \
    libboost-test-dev \
    libboost-python-dev

cabal install happy

cd $DEPENDENCIES_PATH
git clone https://github.com/davisking/dlib.git
cd dlib
python setup.py install
cd examples
mkdir build
cd build
cmake ..
cmake --build . --config Release

# C++ REST SDK

# The C++ REST SDK is a Microsoft project for cloud-based client-server communication in native code using a modern asynchronous C++ API design. 
# This project aims to help C++ developers connect to and interact with services.

cd $DEPENDENCIES_PATH
git clone https://github.com/Microsoft/cpprestsdk
cd cpprestsdk/Release
cmake .
make -j8
make install

# Glog
cd /tmp && \
  wget https://google-glog.googlecode.com/files/glog-0.3.3.tar.gz && \
  tar xzf glog-0.3.3.tar.gz && \
  cd glog-0.3.3 && \
  ./configure && \
  make && make install && \
  cd / && rm -rf /tmp/glog-0.3.3 /tmp/glog-0.3.3.tar.gz

# GFlags
cd /tmp && \
  wget https://github.com/schuhschuh/gflags/archive/master.zip && \
  unzip master.zip && \
  cd gflags-master && \
  mkdir build && cd build && \
  export CXXFLAGS="-fPIC" && cmake .. && make VERBOSE=1 && \
  make install && \
  cd / && rm /tmp/master.zip && rm -rf /tmp/gflags-master

# lmdb
mkdir -p /usr/local/share/man/man1 && \
  cd /tmp && \
  git clone https://github.com/LMDB/lmdb && \
  cd lmdb/libraries/liblmdb && \
  make && make install && \
  cd / && rm -rf /tmp/lmdb

# OpenMPI
cd /tmp && \
  wget http://www.open-mpi.org/software/ompi/v1.8/downloads/openmpi-1.8.7.tar.gz && \
  tar xzvf openmpi-1.8.7.tar.gz && \
  cd /tmp/openmpi-1.8.7 && \
  ./configure --with-cuda --with-threads --enable-mpi-thread-multiple && \
  make && make install && \
  cd / && \
  rm -rf /tmp/openmpi-1.8.7 && \
  rm /tmp/openmpi-1.8.7.tar.gz

# ZeroMQ
cd /tmp && \
  wget http://download.zeromq.org/zeromq-4.1.3.tar.gz && \
  tar xzvf zeromq-4.1.3.tar.gz && \
  cd /tmp/zeromq-4.1.3 && \
  ./configure --without-libsodium && \
  make && make install && \
  cd / && \
  rm -rf /tmp/zeromq-4.1.3 && \
  rm /tmp/zeromq-4.1.3.tar.gz

# H2O
cd $DEPENDENCIES_PATH
git clone https://github.com/h2o/h2o
cd h2o
mkdir -p build 
cd build
cmake ..
make -j8
make install

apt-get install -y libprotobuf-dev libgoogle-glog-dev libtinyxml2-dev protobuf-compiler

# cpp-libface
cd $DEPENDENCIES_PATH
git clone --recursive git@github.com:duckduckgo/cpp-libface.git
cd cpp-libface
make -j8
make install

# Sophus
cd $DEPENDENCIES_PATH
git clone https://github.com/arpg/HAL
cd HAL
mkdir build
cd build
cmake ..
make -j8

# Sophus
cd $DEPENDENCIES_PATH
git clone https://github.com/stevenlovegrove/Sophus
cd Sophus
mkdir build
cd build
cmake ..
make -j8
make install

# libzmqpp
# Build, check, and install libsodium
cd $DEPENDENCIES_PATH
git clone git://github.com/jedisct1/libsodium.git
cd libsodium
./autogen.sh 
./configure && make check 
make install 
ldconfig
cd ../
# Build, check, and install the latest version of ZeroMQ
git clone git://github.com/zeromq/libzmq.git
cd libzmq
./autogen.sh 
./configure --with-libsodium && make -j8
make install
ldconfig
cd ../
# Now install ZMQPP
make -j8
make check
make install
make installcheck

# LIBMILL
cd $DEPENDENCIES_PATH
git clone https://github.com/sustrik/libmill
cd libmill
./autogen.sh
./configure
make -j8
make check
make install

# WSOCK+LIBMILL
cd $DEPENDENCIES_PATH
git clone https://github.com/sustrik/wsock
cd wscok
./autogen.sh
./configure
make -j8
make check

# LIBLUVmake install
cd $DEPENDENCIES_PATH
git clone https://github.com/libuv/libuv
cd libuv
./autogen.sh
./configure
make -j8
make check
make install

# OSRM Project
apt-get install -y libbz2-dev libstxxl-dev libstxxl-doc libstxxl1 libxml2-dev \
libzip-dev libboost-all-dev lua5.1 liblua5.1-0-dev libluabind-dev libluajit-5.1-dev libtbb-dev
cd $DEPENDENCIES_PATH
git clone https://github.com/Project-OSRM/osrm-backend
cd osrm-backend
mkdir build
cd build
cmake ..
make -j8
make install

cd $DEPENDENCIES_PATH
git submodule add https://github.com/zeromq/libzmq.git

cd $DEPENDENCIES_PATH
git submodule add https://github.com/nanomsg/nanomsg

cd $DEPENDENCIES_PATH
git submodule add https://github.com/sustrik/libmill

cd $DEPENDENCIES_PATH
git submodule add https://github.com/h2o/h2o

cd $DEPENDENCIES_PATH
git submodule add https://github.com/Microsoft/bond

cd $DEPENDENCIES_PATH
git submodule add https://github.com/jedisct1/libsodium

cd $DEPENDENCIES_PATH
git submodule add https://github.com/nokia/etcd-cpp-api

cd $DEPENDENCIES_PATH
git submodule add https://github.com/google/protobuf

cd $DEPENDENCIES_PATH
git submodule add https://github.com/eokeeffe/quasi_invariant-features

cd $DEPENDENCIES_PATH
git submodule add https://github.com/azadkuh/qhttp

cd $DEPENDENCIES_PATH
git submodule add https://github.com/willard-yuan/opencv-practical-code

cd $DEPENDENCIES_PATH
git submodule add https://github.com/thierrymalon/DBoW2

cd $DEPENDENCIES_PATH
git submodule add https://github.com/pcolby/libqtaws

cd $DEPENDENCIES_PATH
git submodule add https://github.com/Nava2/QtWebService

cd $DEPENDENCIES_PATH
git submodule add https://github.com/daniel-j-h/DistributedSearch 

cd $DEPENDENCIES_PATH
git submodule add https://github.com/miloyip/rapidjson
