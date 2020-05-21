# build env for OpenSync with QSDK
# base: ubuntu 16.04 64bit (official image)
FROM ubuntu:16.04

# Run apt-get update at each install step because of docker cache
ARG PKGINSTALL="eval apt-get update && apt-get -y install"

# base dev packages
RUN $PKGINSTALL build-essential gcc g++ flex bison gettext texinfo patch ncurses-dev perl automake autoconf libtool cmake

# more dev packages
RUN $PKGINSTALL zlib1g-dev liblzo2-dev uuid-dev openssl libssl-dev
RUN $PKGINSTALL binutils binutils-gold bzip2 make pkg-config libc6-dev subversion libncurses5-dev sharutils curl libxml-parser-perl ocaml-nox
RUN $PKGINSTALL ocaml ocaml-findlib libpcre3-dev dropbear-bin gradle mtd-utils u-boot-tools device-tree-compiler autopoint libmosquitto1
RUN $PKGINSTALL libmosquitto-dev libprotobuf-c1 libprotobuf-c-dev libev4 libev-dev libjansson4 libjansson-dev patchutils openvswitch-switch

# python (for openvswitch)
RUN $PKGINSTALL python python3-dev python3-pip python-pexpect python-tabulate python-termcolor python-paramiko python3-paramiko

# python3 and ovsdb-tool (for schema gen)
RUN $PKGINSTALL python3 openvswitch-switch

# additional packages
RUN $PKGINSTALL wget unzip rsync git-core gawk dos2unix

# optional packages
RUN $PKGINSTALL vim file

# 32bit libs (for sdk: qsdk*/chipcode/.../tools/partition_tool)
RUN dpkg --add-architecture i386
RUN $PKGINSTALL libc6:i386 libstdc++6:i386 zlib1g:i386

# ccache wrappers
RUN $PKGINSTALL libc6-dev-i386 hexec ccache
ADD ucw.tar.xz /usr/src/ucw
RUN cd /usr/src/ucw && make install
COPY hucw /usr/local/bin/hucw

# TARGET=native build requires pcap dev files
RUN $PKGINSTALL libpcap-dev

# Install kconfiglib required for menuconfig
RUN pip3 install kconfiglib

# default cmd
CMD bash -i
