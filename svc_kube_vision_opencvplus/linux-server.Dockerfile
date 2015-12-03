FROM ubuntu:14.04

RUN apt-get update && apt-get install -q -y \
  wget \
  curl \
  git \
  unzip \
  cmake \
  libboost-all-dev \
  libeigen3-dev \
  libgflags-dev \
  libgoogle-glog-dev \
  libleveldb-dev \
  liblmdb-dev \
  libprotobuf-dev \
  libsnappy-dev \
  protobuf-compiler \
  python-dev \
  python-pip \
  ca-certificates \
  openssl \
  libffi-dev \
  libssl-dev

RUN cd /tmp && \
  wget http://www.open-mpi.org/software/ompi/v1.10/downloads/openmpi-1.10.0.tar.gz && \
  tar xzvf openmpi-1.10.0.tar.gz && \
  cd /tmp/openmpi-1.10.0 && \
  ./configure --with-threads --enable-mpi-thread-multiple && \
  make -j12 && make install && \
  cd / && \
  rm -rf /tmp/openmpi-1.10.0 && \
  rm /tmp/openmpi-1.10.0.tar.gz

# Caffe2 requires zeromq 4.0 or above, manually install.
# If you do not need zeromq, skip this step.
RUN cd /tmp && \
  wget http://download.zeromq.org/zeromq-4.1.3.tar.gz && \
  tar xzvf zeromq-4.1.3.tar.gz && \
  cd /tmp/zeromq-4.1.3 && \
  ./configure --without-libsodium && \
  make -j12 && make install && \
  cd / && \
  rm -rf /tmp/zeromq-4.1.3 && \
  rm /tmp/zeromq-4.1.3.tar.gz

RUN mkdir -p /src/app
WORKDIR /src/app/

RUN cd /src && \
    curl -L \
         https://github.com/davisking/dlib/releases/download/v18.16/dlib-18.16.tar.bz2 \
         -o dlib.tar.bz2 && \
    tar xf dlib.tar.bz2 && \
    cd dlib-18.16/python_examples && \
    mkdir build && \
    cd build && \
    cmake ../../tools/python && \
    cmake --build . --config Release && \
    cp dlib.so ..

RUN cd /src && \
    curl -O https://storage.googleapis.com/golang/go1.5.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.5.0.linux-amd64.tar.gz && \
    mkdir -p ~/go; echo "export GOPATH=$HOME/go" >> ~/.bashrc && \
    echo "export PATH=$PATH:$HOME/go/bin:/usr/local/go/bin" >> ~/.bashrc

RUN cd /src/ && \
    git clone https://github.com/miloyip/rapidjson.git && \
    cd rapidjson && \
    git submodule update --init && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j8 && \
    make install 

RUN apt-get install -y libmicrohttpd-dev libjsoncpp-dev && \
    apt-get -y autoremove; \
    apt-get -y autoclean

RUN cd /src && \
    git clone https://github.com/dorian3d/DLib.git && \
    cd DLib && \
    mkdir -p build && \
    cd build && \
    cmake .. && \
    make -j8 && \
    make install

RUN cd /src && \
    git submodule add https://github.com/zeromq/libzmq.git && \
    git submodule add https://github.com/nanomsg/nanomsg && \
    git submodule add https://github.com/sustrik/libmill && \
    git submodule add https://github.com/h2o/h2o && \
    git submodule add https://github.com/Microsoft/bond && \
    git submodule add https://github.com/jedisct1/libsodium && \
    git submodule add https://github.com/nokia/etcd-cpp-api && \
    git submodule add https://github.com/google/protobuf && \
    git submodule add https://github.com/eokeeffe/quasi_invariant-features && \
    git submodule add https://github.com/azadkuh/qhttp && \
    git submodule add https://github.com/willard-yuan/opencv-practical-code && \
    git submodule add https://github.com/thierrymalon/DBoW2 && \
    git submodule add https://github.com/pcolby/libqtaws && \
    git submodule add https://github.com/Nava2/QtWebService && \
    git submodule add https://github.com/daniel-j-h/DistributedSearch  && \
    git submodule add https://github.com/miloyip/rapidjson && \
    git submodule add https://github.com/vinipsmaker/tufao && \
    git submodule add https://github.com/redis/hiredis && \
    git submodule add https://github.com/dimatura/hdf5opencv && \
    git submodule add https://github.com/regisb/onbnn

#libev
WORKDIR /src/
RUN wget http://dist.schmorp.de/libev/Attic/libev-4.04.tar.gz && \
tar xfzv libev-4.04.tar.gz && \
rm -f libev-4.04.tar.gz && \
cd libev-4.04/ && \
./configure --prefix=/opt/dionaea --disable-werror && \
make -j8 install

#python 3.3
WORKDIR /src/
RUN wget http://www.python.org/ftp/python/3.2.2/Python-3.2.2.tgz && \
tar xfzv Python-3.2.2.tgz && \
cd Python-3.2.2/ && \
rm Python-3.2.2.tgz && \
./configure --enable-shared --prefix=/opt/dionaea --with-computed-gotos --enable-ipv6 LDFLAGS="-Wl,-rpath=/opt/dionaea/lib/ -L/usr/lib/x86_64-linux-gnu/" && \
make -j8 && \
make install

WORKDIR /src/
RUN git clone https://github.com/xianyi/OpenBLAS.git /src/OpenBLAS
RUN cd /src/OpenBLAS && make NO_AFFINITY=1 USE_OPENMP=1 -j8 && make install

WORKDIR /src/
RUN git clone https://github.com/Itseez/opencv.git
RUN git clone https://github.com/Itseez/opencv_contrib.git

RUN git clone --depth 1 https://github.com/l-smash/l-smash

RUN mkdir /src/opencv/build
WORKDIR /src/opencv/build
RUN cmake -DBUILD_TIFF=ON -DBUILD_opencv_java=OFF -DWITH_CUDA=OFF -DENABLE_AVX=ON -DWITH_OPENGL=ON -DWITH_OPENCL=ON -DWITH_IPP=OFF -DWITH_TBB=ON -DWITH_EIGEN=ON -DWITH_V4L=ON \
          -DWITH_QT=4 -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=$(python3 -c "import sys; print(sys.prefix)") \
          -DOPENCV_EXTRA_MODULES_PATH=/src/opencv_contrib/modules \
          -DPYTHON_EXECUTABLE=$(which python3) \
          -DPYTHON_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") -DPYTHON_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import \
          get_python_lib; print(get_python_lib())") ..

RUN make -j8
RUN make install

RUN mkdir -p /src/app
WORKDIR /src/app/

RUN git clone https://github.com/introlab/find-object.git && \
    cd find-object && \
    mkdir -p build

ENV LD_LIBRARY_PATH /usr/local/lib:/opt/OpenBLAS/lib:$LD_LIBRARY_PATH

ADD build.sh /src/app/build.sh
RUN chmod +x /src/app/build.sh
ENV LD_LIBRARY_PATH /usr/local/lib:/usr/lib/x86_64-linux-gnu/:/usr/lib:/opt/OpenBLAS/lib:/usr/include:$LD_LIBRARY_PATH
CMD ["/bin/bash"]
