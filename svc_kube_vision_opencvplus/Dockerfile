FROM ubuntu:14.04
MAINTAINER Luc Michalski <lucmichalski@blippar.com>

ENV DEBIAN_FRONTEND noninteractive
ENV SIRIUS_HOME /opt/find-object
RUN export FIND_HOME=$FIND_HOME

RUN apt-get update && apt-get install -y \
        python-software-properties

RUN echo 'deb http://archive.ubuntu.com/ubuntu precise multiverse' >> /etc/apt/sources.list

RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test \
        && add-apt-repository -y ppa:tuleu/precise-backports

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

WORKDIR /src/
RUN git clone https://github.com/xianyi/OpenBLAS.git /src/OpenBLAS
RUN cd /src/OpenBLAS && make NO_AFFINITY=1 USE_OPENMP=1 -j8 && make install

RUN git clone https://github.com/Itseez/opencv.git
RUN git clone https://github.com/Itseez/opencv_contrib.git

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

ADD build.sh /src/app/build.sh
RUN chmod +x /src/app/build.sh
ENV LD_LIBRARY_PATH /usr/local/lib:/usr/lib/x86_64-linux-gnu/:/usr/lib:/opt/OpenBLAS/lib:/usr/include:$LD_LIBRARY_PATH
CMD ["/bin/bash"]
