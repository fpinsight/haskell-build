#!/usr/bin/env bash

# Work in progress: create a list of commands necessary to get Stackage
# up-and-running on a freshly installed Debian-based system (including Ubuntu).

# Quick start:
# wget -O - https://raw.github.com/fpco/stackage/master/debian-bootstrap.sh | bash -ex

# NOTE: Requires that GHC and Cabal are installed and on your PATH. For
# instructions, see:
#    http://www.stackage.org/install

set -exu

mkdir /home/stackage -p

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y software-properties-common

add-apt-repository ppa:hvr/ghc -y
add-apt-repository -y ppa:marutter/rrutter

# Set the GHC version
GHCVER=8.0.2

OCILIBVER=4.3.2
RDKAFKAVER=0.9.4
FBTHRIFTVER=2017.03.13.00
FOLLY_VERSION=master
WANGLE_VERSION=master
MESOS_VERSION=1.2.0

apt-get update
apt-get install -y \
    build-essential \
    ghc-$GHCVER \
    ghc-$GHCVER-dyn \
    ghc-$GHCVER-prof \
    ghc-$GHCVER-htmldocs \
    hscolour \
    sudo \
    curl \
    freeglut3-dev \
    git \
    gradle \
    libadns1-dev \
    libaio1 \
    libalut-dev \
    libasound2-dev \
    libblas-dev \
    libbz2-dev \
    libcairo2-dev \
    libclang-3.7-dev \
    libcurl4-openssl-dev \
    libdevil-dev \
    libedit-dev \
    libedit2 \
    libfftw3-dev \
    libflac-dev \
    libfreenect-dev \
    libgd2-xpm-dev \
    libgeoip-dev \
    libgirepository1.0-dev \
    libglfw3-dev \
    libglib2.0-dev \
    libglu1-mesa-dev \
    libgmp3-dev \
    libgnutls-dev \
    libgsasl7-dev \
    libgsl0-dev \
    libgtk-3-dev \
    libgtk2.0-dev \
    libgtksourceview-3.0-dev \
    libhidapi-dev \
    libicu-dev \
    libjudy-dev \
    liblapack-dev \
    libleveldb-dev \
    liblmdb-dev \
    liblzma-dev \
    libmagic-dev \
    libmagickcore-dev \
    libmagickwand-dev \
    libmarkdown2-dev \
    libmp3lame-dev \
    libmpfr-dev \
    libmysqlclient-dev \
    libncurses-dev \
    libnfc-dev \
    libnotify-dev \
    libopenal-dev \
    libpango1.0-dev \
    libpcap0.8-dev \
    libpq-dev \
    libsdl2-dev \
    libsdl2-mixer-dev \
    libsdl2-image-dev \
    libsdl2-gfx-dev \
    libsdl2-ttf-dev \
    libsnappy-dev \
    libsndfile1-dev \
    libsqlite3-dev \
    libssl-dev \
    libsystemd-dev \
    libtagc0-dev \
    libtre-dev \
    libudev-dev \
    libusb-1.0-0-dev \
    libwebkitgtk-3.0-dev \
    libxau-dev \
    libxml2-dev \
    libxrandr-dev \
    libxss-dev \
    libyaml-dev \
    libzip-dev \
    libzmq3-dev \
    libzookeeper-mt-dev \
    llvm-3.7 \
    locales \
    m4 \
    nettle-dev \
    wget \
    xclip \
    z3 \
    zip \
    zlib1g-dev \
    libdouble-conversion-dev \
    libssl-dev \
    autoconf \
    libtool \
    libboost-all-dev \
    libevent-dev \
    flex \
    bison \
    libgoogle-glog-dev \
    scons \
    libkrb5-dev \
    libsasl2-dev \
    libnuma-dev \
    cmake \
    pkg-config \
    openjdk-8-jdk \
    maven \
    libapr1-dev \
    libsvn-dev \
    automake

#    nodejs \
#    npm \
    #    openjdk-8-jdk \
#    python-mpltoolkits.basemap \
#    python3-matplotlib \
#    python3-numpy \
#    python3-pip \
#    r-base \
#    r-base-dev \
#    ruby-dev \


apt-get clean

locale-gen en_US.UTF-8

curl -sSL https://get.haskellstack.org/ | sh

# Put documentation where we expect it
mv /opt/ghc/$GHCVER/share/doc/ghc-$GHCVER/ /opt/ghc/$GHCVER/share/doc/ghc

# Buggy versions of ld.bfd fail to link some Haskell packages:
# https://sourceware.org/bugzilla/show_bug.cgi?id=17689. Gold is
# faster anyways and uses less RAM.
update-alternatives --install "/usr/bin/ld" "ld" "/usr/bin/ld.gold" 20
update-alternatives --install "/usr/bin/ld" "ld" "/usr/bin/ld.bfd" 10

# GHC requires a specific LLVM version on the system PATH for its LLVM backend.
# This version is tracked here:
# https://ghc.haskell.org/trac/ghc/wiki/Commentary/Compiler/Backends/LLVM/Installing
#
# GHC 8.0 requires LLVM 3.7 tools (specifically, llc-3.7 and opt-3.7).
update-alternatives --install "/usr/bin/llc" "llc" "/usr/bin/llc-3.7" 50
update-alternatives --install "/usr/bin/opt" "opt" "/usr/bin/opt-3.7" 50

# install ocilib dependencies then build and install ocilib
cd /tmp \
    && wget https://storage.googleapis.com/oracle.fpinsight.com/instantClient/oracle-instantclient12.1-basiclite_12.1.0.2.0-2_amd64.deb \
    && dpkg -i oracle-instantclient12.1-basiclite_12.1.0.2.0-2_amd64.deb \
    && rm -f oracle-instantclient12.1-basiclite_12.1.0.2.0-2_amd64.deb \
    && wget https://storage.googleapis.com/oracle.fpinsight.com/instantClient/oracle-instantclient12.1-devel_12.1.0.2.0-2_amd64.deb \
    && dpkg -i oracle-instantclient12.1-devel_12.1.0.2.0-2_amd64.deb \
    && rm -f oracle-instantclient12.1-devel_12.1.0.2.0-2_amd64.deb \
    && wget https://github.com/vrogier/ocilib/archive/v$OCILIBVER.tar.gz \
    && tar xvf v$OCILIBVER.tar.gz \
    && cd /tmp/ocilib-$OCILIBVER \
    && ./configure --with-oracle-import=linkage \
                   --with-oracle-charset=ansi \
                   --with-oracle-headers-path=/usr/include/oracle/12.1/client64 \
                   --with-oracle-lib-path=/usr/lib/oracle/12.1/client64/lib \
    && make -j 2 V=0 \
    && make install \
    && cd \
    && rm -rf /tmp/ocilib-$OCILIBVER \
    && echo "/usr/local/lib" > /etc/ld.so.conf.d/usr-local.conf \
    && echo "/usr/lib/oracle/12.1/client64/lib" > /etc/ld.so.conf.d/oracle-client.conf \
    && ldconfig \
    && rm -rf /tmp/ocilib-$OCILIBVER


# librdkafka
cd /tmp \
    && wget https://github.com/edenhill/librdkafka/archive/v$RDKAFKAVER.tar.gz \
    && tar xvf /tmp/v$RDKAFKAVER.tar.gz \
    && cd /tmp/librdkafka-$RDKAFKAVER \
    && ./configure \
    && make -j 2 V=0 \
    && sudo make install \
    && rm -rf /tmp/librdkafka-$RDKAFKAVER

# fbthrift
cd /tmp \
    && git clone https://github.com/no1msd/mstch \
    && cd mstch \
    && cmake . \
    && make -j 2 V=0 \
    && sudo make install \
    && rm -rf /tmp/mstch

cd /tmp \
    && git clone https://github.com/facebook/zstd \
    && cd zstd \
    && make -j 2 V=0 \
    && sudo make install \
    && rm -rf /tmp/zstd

cd /tmp \
    && git clone https://github.com/facebook/folly \
    && cd folly/folly \
    && git checkout "$FOLLY_VERSION" \
    && autoreconf -if \
    && ./configure \
    && make -j 2 V=0 \
    && sudo make install \
    && sudo ldconfig \
    && rm -rf /tmp/folly

cd /tmp \
    && git clone https://github.com/facebook/wangle \
    && cd wangle/wangle \
    && git checkout "$WANGLE_VERSION" \
    && cmake . \
    && make -j 2 V=0 \
    && sudo make install \
    && rm -rf /tmp/wangle

cd /tmp \
    && wget https://github.com/facebook/fbthrift/archive/v$FBTHRIFTVER.tar.gz \
    && tar xvf /tmp/v$FBTHRIFTVER.tar.gz \
    && cd fbthrift-$FBTHRIFTVER \
    && cd thrift \
    && autoreconf -ivf \
    && ./configure \
    && make -j 2 V=0 \
    && sudo make install \
    && rm -rf fbthrift-$FBTHRIFTVER

# Add JDK to system paths.
echo "/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server/" > /etc/ld.so.conf.d/openjdk.conf \
    && ldconfig

# mesos
cd /tmp \
    && wget http://www.apache.org/dist/mesos/$MESOS_VERSION/mesos-$MESOS_VERSION.tar.gz \
    && tar -zxf mesos-$MESOS_VERSION.tar.gz \
    && cd /tmp/mesos-$MESOS_VERSION \
    && mkdir build \
    && cd build \
    && ../configure LIBS=-ldl \
    && make -j 2 V=0 \
    && sudo make install \
    && rm -rf /tmp/mesos-$MESOS_VERSION

cd /tmp
