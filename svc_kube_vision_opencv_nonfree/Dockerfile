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
RUN make -j7
RUN make install

#ssh configs
RUN mkdir /root/.ssh
RUN mkdir /var/run/sshd

ADD sshkey.pub /root/.ssh/authorized_keys
RUN chown root:root /root/.ssh/authorized_keys
RUN sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config

RUN cd /src/ && \
    git clone https://github.com/introlab/find-object.git && \
    cd find_object/build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j8 && \
    cd ../bin && \
    ls -l

RUN mkdir -p /var/log/supervisor
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf


EXPOSE 22
CMD env | grep _ >> /etc/environment && /usr/bin/supervisord
