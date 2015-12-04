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
  libssl-dev \
  qtdeclarative5-dev \
  qt5-default \
  qttools5-dev-tools \
  libmicrohttpd-dev \
  libjsoncpp-dev && \
  apt-get -y autoremove; \
  apt-get -y autoclean

RUN cd /usr/local/src && \
  wget http://www.open-mpi.org/software/ompi/v1.10/downloads/openmpi-1.10.0.tar.gz && \
  tar xzvf openmpi-1.10.0.tar.gz && \
  cd /usr/local/src/openmpi-1.10.0 && \
  ./configure --with-threads --enable-mpi-thread-multiple && \
  make -j12 && make install && \
  cd / && \
  rm -rf /usr/local/src/openmpi-1.10.0 && \
  rm /usr/local/src/openmpi-1.10.0.tar.gz

# Caffe2 requires zeromq 4.0 or above, manually install.
# If you do not need zeromq, skip this step.
RUN cd /usr/local/src && \
  wget http://download.zeromq.org/zeromq-4.1.3.tar.gz && \
  tar xzvf zeromq-4.1.3.tar.gz && \
  cd /usr/local/src/zeromq-4.1.3 && \
  ./configure --without-libsodium && \
  make -j12 && make install && \
  cd / && \
  rm -rf /usr/local/src/zeromq-4.1.3 && \
  rm /usr/local/src/zeromq-4.1.3.tar.gz

WORKDIR /usr/local/src/
RUN git clone https://github.com/Itseez/opencv.git
RUN git clone https://github.com/Itseez/opencv_contrib.git

RUN mkdir -p /usr/local/src/opencv/build
WORKDIR /usr/local/src/opencv/build
RUN cmake -DBUILD_TIFF=ON -DBUILD_opencv_java=OFF -DWITH_CUDA=OFF -DENABLE_AVX=ON -DWITH_OPENGL=ON -DWITH_OPENCL=ON -DWITH_IPP=OFF -DWITH_TBB=ON -DWITH_EIGEN=ON -DWITH_V4L=ON \
          -DWITH_QT=5 -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=$(python3 -c "import sys; print(sys.prefix)") \
          -DOPENCV_EXTRA_MODULES_PATH=/usr/local/src//opencv_contrib/modules \
          -DPYTHON_EXECUTABLE=$(which python3) \
          -DPYTHON_INCLUDE_DIR=$(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") -DPYTHON_PACKAGES_PATH=$(python3 -c "from distutils.sysconfig import \
          get_python_lib; print(get_python_lib())") ..

RUN make -j4
RUN make install

RUN mkdir -p /usr/local/src/app

RUN cd /usr/local/src/ && \
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

RUN cd /usr/local/src && \
    curl -O https://storage.googleapis.com/golang/go1.5.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.5.0.linux-amd64.tar.gz && \
    mkdir -p ~/go; echo "export GOPATH=$HOME/go" >> ~/.bashrc && \
    echo "export PATH=$PATH:$HOME/go/bin:/usr/local/go/bin" >> ~/.bashrc

RUN cd /usr/local/src/ && \
    git clone https://github.com/miloyip/rapidjson.git && \
    cd rapidjson && \
    git submodule update --init && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j4 && \
    make install 

ENV LD_LIBRARY_PATH /usr/local/lib:/opt/OpenBLAS/lib:$LD_LIBRARY_PATH

ADD build.sh /src/app/build.sh
RUN chmod +x /src/app/build.sh
ENV LD_LIBRARY_PATH /usr/local/lib:/usr/lib/x86_64-linux-gnu/:/usr/lib:/opt/OpenBLAS/lib:/usr/include:$LD_LIBRARY_PATH
CMD ["/bin/bash"]
