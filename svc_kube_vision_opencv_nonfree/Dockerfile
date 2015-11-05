FROM ubuntu:trusty

# Install packages
ENV DEBIAN_FRONTEND noninteractive

# Set locale (fix the locale warnings)
RUN locale-gen --purge en_US.UTF-8
RUN echo  'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' > /etc/default/locale

# Set timezone
RUN echo "America/New-York"  > /etc/timezone
RUN dpkg-reconfigure --frontend noninteractive tzdata

#RUN rm /etc/apt/sources.list
#ADD sources.list /etc/apt/sources.list

RUN apt-get -y update
RUN apt-get -y install supervisor  openssh-server  python-software-properties software-properties-common python-pip git nano curl tmux htop mc
RUN apt-get install -y build-essential cmake libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev python-dev python-numpy libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev ocl-icd-opencl-dev libcanberra-gtk3-module cmake libqt4-dev
RUN pip install matplotlib
RUN apt-get install -y \
    build-essential \
    cmake \
    curl \
    gfortran \
    git \
    libatlas-dev \
    libavcodec-dev \
    libavformat-dev \
    libboost-all-dev \
    libgtk2.0-dev \
    libjpeg-dev \
    liblapack-dev \
    libswscale-dev \
    pkg-config \
    python-dev \
    python-pip \
    wget \
    zip \
    vim \
    apache2
RUN pip2 install numpy scipy pandas
RUN pip2 install scikit-learn scikit-image

RUN mkdir /src
WORKDIR /src
RUN git clone https://github.com/Itseez/opencv.git
RUN git clone https://github.com/Itseez/opencv_contrib.git

RUN mkdir /src/opencv/build
WORKDIR /src/opencv/build
RUN cmake -D CMAKE_BUILD_TYPE=RELEASE \
		  -D BUILD_PYTHON_SUPPORT=ON \
		  -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules/  \
		  -D CMAKE_INSTALL_PREFIX=/usr/local \
		  -D WITH_OPENGL=ON \
		  -D WITH_TBB=ON \
		  -D BUILD_EXAMPLES=ON \
		  -D BUILD_NEW_PYTHON_SUPPORT=ON \
		  -D WITH_V4L=ON \
		  ..
RUN make -j8
RUN make install

RUN mkdir -p /src/dlib && \
    cd /src/dlib && \
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
    git clone https://github.com/introlab/find-object.git && \
    mkdir -p find-object/build && \
    cd find-object/build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j8 && \
    cd ../bin && \
    ls -l

CMD /bin/bash
