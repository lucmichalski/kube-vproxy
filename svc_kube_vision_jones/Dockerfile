FROM ubuntu:12.04
MAINTAINER Luc Michalski <lucmichalski@blippar.com>

ENV DEBIAN_FRONTEND noninteractive
ENV SIRIUS_HOME /opt/sirius
RUN export SIRIUS_HOME=$SIRIUS_HOME 

RUN apt-get update && apt-get install -y \
	python-software-properties

RUN echo 'deb http://archive.ubuntu.com/ubuntu precise multiverse' >> /etc/apt/sources.list

RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test \
	&& add-apt-repository -y ppa:tuleu/precise-backports

RUN apt-get update && apt-get install -y \
	openjdk-7-jdk \
	sox \
	unzip \
	wget \
	git \
	curl \
	make \
	cmake \
        gcc-multilib \
	subversion \
	python-dev \
	python-numpy \
	python-dev \
	python-pip \
	libleveldb-dev \
	libsnappy-dev \
	libboost-dev \
	libboost-system-dev \
	libboost-python-dev \
	libboost-thread-dev \
	libprotobuf-dev \
	libfaac-dev \
	libatlas-base-dev \
	libblas-dev libopenblas-dev \
	libhdf5-serial-dev \
	libgflags-dev \
	libgoogle-glog-dev \
	bc \
	gcc-4.8 \
	g++-4.8 \
	tesseract-ocr \
	tesseract-ocr-eng \
	libtesseract-dev \
	libleptonica-dev \
	libatlas-dev \
	ant \
	automake \
	autoconf \
	libtool \
	bison \
	libboost-all-dev \
	ffmpeg \
	swig \
	build-essential \
	checkinstall \
	libjack-jackd2-dev \
	libmp3lame-dev \
	libopencore-amrnb-dev \
	libopencore-amrwb-dev \
	libsdl1.2-dev \
	libtheora-dev \
	libva-dev \
	libvdpau-dev \
	libvorbis-dev \
	libx11-dev \
	libxfixes-dev \
	libxvidcore-dev \
	texi2html \
	yasm \
	zlib1g-dev \
        openssl

RUN curl -k -# -O https://protobuf.googlecode.com/files/protobuf-2.5.0.tar.gz \
    && tar -xzvf protobuf-2.5.0.tar.gz \
    && cd protobuf-2.5.0 \
    && ./configure --prefix=/usr \
    && make \
    && make install

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 50 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 50 \
    && update-java-alternatives -s /usr/lib/jvm/java-1.7.0-openjdk-amd64

RUN pip install --upgrade pip
RUN pip install --upgrade virtualenv
RUN pip install pickledb

#Download sirius source
RUN git clone --progress --verbose https://github.com/jhauswald/sirius.git --branch master $SIRIUS_HOME

#Setting up sirius
WORKDIR $SIRIUS_HOME/sirius-application
RUN ./get-dependencies.sh
RUN ./get-kaldi.sh
RUN ./get-opencv.sh
RUN ./compile-sirius-servers.sh



#Automatic Speech Recognition(ASR)
RUN $SIRIUS_HOME/sirius-application/run-scripts/start-asr-server.sh

#Image Matching(IMM)
RUN $SIRIUS_HOME/sirius-application/image-matching/make-db.py landmarks $SIRIUS_HOME/sirius-application/image-matching/matching/landmarks/db/
RUN $SIRIUS_HOME/sirius-application/image-matching/start-imm-server.sh

#Question-Answering System(QA)
