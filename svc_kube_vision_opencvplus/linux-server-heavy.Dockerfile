FROM ubuntu:14.04

ENV YASM_VERSION    1.3.0

RUN apt-get update && apt-get install -q -y \
  wget \
  curl \
  qtbase5-dev \
  qtdeclarative5-dev \
  qtconnectivity5-dev \
  git \
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

# Caffe2 works best with openmpi 1.8.5 or above (which has cuda support).
# If you do not need openmpi, skip this step.
RUN cd /tmp && \
  wget http://www.open-mpi.org/software/ompi/v1.10/downloads/openmpi-1.10.0.tar.gz && \
  tar xzvf openmpi-1.10.0.tar.gz && \
  cd /tmp/openmpi-1.10.0 && \
  ./configure --with-threads --enable-mpi-thread-multiple && \
  make && make install && \
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
  make && make install && \
  cd / && \
  rm -rf /tmp/zeromq-4.1.3 && \
  rm /tmp/zeromq-4.1.3.tar.gz

#install deps
RUN apt-get update && \
apt-get install -y libudns-dev libglib2.0-dev libssl-dev libcurl4-openssl-dev libreadline-dev libsqlite3-dev python-dev libtool automake autoconf build-essential subversion git-core \
 flex bison pkg-config wget -y

#make build and install dir
RUN mkdir -p /opt/dionaea
WORKDIR /opt/dionaea/

#libev
RUN wget http://dist.schmorp.de/libev/Attic/libev-4.04.tar.gz && \
tar xfzv libev-4.04.tar.gz && \
cd libev-4.04/ && \
./configure --prefix=/opt/dionaea --disable-werror && \
make install

#python 3.3
RUN wget http://www.python.org/ftp/python/3.2.2/Python-3.2.2.tgz && \
tar xfzv Python-3.2.2.tgz && \
cd Python-3.2.2/ && \
./configure --enable-shared --prefix=/opt/dionaea --with-computed-gotos --enable-ipv6 LDFLAGS="-Wl,-rpath=/opt/dionaea/lib/ -L/usr/lib/x86_64-linux-gnu/" && \
make && \
make install

#cython
RUN wget http://cython.org/release/Cython-0.15.tar.gz && \
tar xfzv Cython-0.15.tar.gz && \
cd Cython-0.15/ && \
/opt/dionaea/bin/python3 setup.py install

# pip self upgrade
RUN pip install --upgrade pip

# Python dependencies
RUN pip install \
  numpy \
  protobuf

################################################################################
# Step 3: install optional dependencies ("good to have" features)
################################################################################

RUN apt-get install -q -y \
  gfortran \
  graphviz \
  libatlas-base-dev \
  vim \
    libtiff5-dev \
    libjpeg8-dev \
    zlib1g-dev \
    libfreetype6-dev \
    libxft-dev \
    pkg-config \
    python2.7 \
    python-dev \
    python-pip \
    tmux \
    curl \
    nano \
    vim \
    git \
    htop \
    man \
    software-properties-common \
    unzip \
    wget \
    libncurses5-dev \
    readline-common

RUN apt-get build-dep -y python-matplotlib

RUN pip install \
  flask \
  ipython \
  notebook \
  pydot \
  python-nvd3 \
  scipy \
  tornado \
  scikit-image

# This is intentional. scikit-image has to be after scipy.
RUN pip install  scikit-image

################################################################################
# Step 4: set up caffe2
################################################################################

# Get the repository, and build.
RUN cd /opt && \
  git clone https://github.com/Yangqing/caffe2.git && \
  cd /opt/caffe2 && \
  make

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1

RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

# Form a set of standard directories.
RUN mkdir -p /downloads
RUN mkdir -p /work

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1


# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

RUN apt-get update && apt-get -y install cmake imagemagick && \
    apt-get -y install libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev && \
    apt-get -y install libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev && \
    cd /usr/local/src && wget http://downloads.sourceforge.net/libpng/libpng-1.6.17.tar.xz && \
    tar -xf libpng-1.6.17.tar.xz && cd libpng-1.6.17 && \
    ./configure --prefix=/usr --disable-static && make && make install

RUN apt-get -y install libgeos-dev && \
    cd /usr/local/src && git clone https://github.com/matplotlib/basemap.git && \
    export GEOS_DIR=/usr/local && \
    cd basemap && python setup.py install && \
    # Pillow (PIL)
    apt-get -y install zlib1g-dev liblcms2-dev libwebp-dev && \
    pip install Pillow && \
    cd /usr/local/src && git clone https://github.com/vitruvianscience/opendeep.git && \
    cd opendeep && python setup.py develop

RUN apt-get install -y software-properties-common python-software-properties
    
RUN cd /usr/local/src && git clone https://github.com/matplotlib/matplotlib.git && \
    cd matplotlib && mv setup.cfg.template setup.cfg && echo "backend = Agg" >> setup.cfg && \
    python setup.py build && python setup.py install

RUN apt-get install -y python-software-properties && \
    add-apt-repository "deb http://archive.ubuntu.com/ubuntu trusty main" && \
    apt-get install debian-archive-keyring && apt-key update && apt-get update && \
    apt-get install --force-yes -y ubuntu-keyring && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 40976EAF437D05B5 3B4FE6ACC0B21F32 && \
    mv /var/lib/apt/lists /tmp && mkdir -p /var/lib/apt/lists/partial && \
    apt-get clean && apt-get update && apt-get install -y g++-4.8 && \
    cd /usr/local/src && git clone --recursive https://github.com/dmlc/mxnet && \
    cd /usr/local/src/mxnet && cp make/config.mk . && sed -i 's/CC = gcc/CC = gcc-4.8/' config.mk && \
    sed -i 's/CXX = g++/CXX = g++-4.8/' config.mk && \
    sed -i 's/ADD_LDFLAGS =/ADD_LDFLAGS = -lstdc++/' config.mk && \
    make && cd python && python setup.py install

RUN apt-get -y install supervisor  openssh-server  python-software-properties software-properties-common python-pip git nano curl tmux htop mc
RUN apt-get install -y build-essential cmake libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev python-dev python-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev \
                       libtiff-dev libjasper-dev libdc1394-22-dev ocl-icd-opencl-dev libcanberra-gtk3-module cmake 

RUN cd /usr/local/src && \
    wget http://www.cmake.org/files/v3.2/cmake-3.2.2.tar.gz && \
    tar xf cmake-3.2.2.tar.gz  && \
    cd cmake-3.2.2 && \
    ./configure && \
    make -j8 && \
    make install

RUN add-apt-repository ppa:ubuntu-toolchain-r/test && \
    apt-get update -y && \
    apt-get install -y  gcc-4.9 g++-4.9 cpp-4.9 libboost-all-dev

RUN apt-get install -f
RUN pip install numpy scipy

RUN cd /src && \
    curl -O https://storage.googleapis.com/golang/go1.5.0.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.5.0.linux-amd64.tar.gz && \
    mkdir -p ~/go; echo "export GOPATH=$HOME/go" >> ~/.bashrc && \
    echo "export PATH=$PATH:$HOME/go/bin:/usr/local/go/bin" >> ~/.bashrc

RUN pip install matplotlib && updatedb

RUN apt-get install -y build-essential

RUN apt-get install -y cmake
RUN apt-get install -y curl
RUN apt-get install -y libreadline-dev
RUN apt-get install -y git-core
RUN apt-get install -y libqt4-core libqt4-gui libqt4-dev
RUN apt-get install -y libjpeg-dev
RUN apt-get install -y libpng-dev
RUN apt-get install -y ncurses-dev
RUN apt-get install -y imagemagick
RUN apt-get install -y libzmq3-dev
RUN apt-get install -y gfortran
RUN apt-get install -y unzip
RUN apt-get install -y gnuplot
RUN apt-get install -y gnuplot-x11
RUN apt-get install -y libsdl2-dev
RUN apt-get install -y libgraphicsmagick1-dev
RUN apt-get install -y nodejs
RUN apt-get install -y npm
RUN apt-get install -y libfftw3-dev sox libsox-dev libsox-fmt-all clang \
    cmake \
    zlib1g-dev \
    ghc \
    cabal-install \
    libboost-dev \
    libboost-thread-dev \
    python2.7-dev \
    libboost-date-time-dev \
    libboost-test-dev \
    libboost-python-dev \
    mercurial \
    python-qt4

RUN apt-get install -y build-essential libtcmalloc-minimal4 && \
    ln -s /usr/lib/libtcmalloc_minimal.so.4 /usr/lib/libtcmalloc_minimal.so

RUN cabal update && \
    cabal install cabal-install && \
    cabal install happy

RUN mkdir /src
WORKDIR /src

RUN apt-get update -y
RUN git clone https://github.com/xianyi/OpenBLAS.git /src/OpenBLAS
RUN cd /src/OpenBLAS && make NO_AFFINITY=1 USE_OPENMP=1 -j8 && make install

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

RUN cd ~ && \
    mkdir -p src && \
    cd src && \
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

RUN cd /src/ && \
    git clone https://github.com/miloyip/rapidjson.git && \
    cd rapidjson && \
    git submodule update --init && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j8 && \
    make install 

RUN cd /src/ && \
    git clone --recursive https://github.com/Microsoft/bond.git && \
    cd /src/bond && \
    mkdir /src/bond/build && \
    cd build && \
    cmake .. && \
    make -j8 && \
    make install   

RUN cd /src/ && \
    git clone https://github.com/nanomsg/nanomsg.git && \
    cd nanomsg && \
    sh autogen.sh && \
    ./configure && \
    make -j8 && \
    make check && \
    make install

RUN apt-get install -y libmicrohttpd-dev libjsoncpp-dev && \
    apt-get -y autoremove; \
    apt-get -y autoclean

# Build DLib official Repo
RUN cd /src && \
    git clone https://github.com/davisking/dlib.git && \
    cd dlib && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j8 && \
    make install



ADD build.sh /src/app/build.sh
RUN chmod +x /src/app/build.sh
ENV LD_LIBRARY_PATH /usr/local/lib:/usr/lib/x86_64-linux-gnu/:/usr/lib:/opt/OpenBLAS/lib:/usr/include:$LD_LIBRARY_PATH
CMD ["/bin/bash"]
