FROM ubuntu:latest AS crosstool

RUN apt-get update
RUN apt-get install -y gcc g++ gperf bison flex texinfo help2man make libncurses5-dev \
  python3-dev autoconf automake libtool libtool-bin gawk wget bzip2 xz-utils unzip \
  patch rsync meson ninja-build

# Install crosstool-ng
ENV PKG=crosstool-ng-1.27.0
RUN wget https://github.com/crosstool-ng/crosstool-ng/releases/download/$PKG/$PKG.tar.bz2
RUN tar -xjf $PKG.tar.bz2
RUN cd $PKG && ./configure --prefix=/$PKG/out && make && make install
ENV PATH=$PATH:/$PKG/out/bin
ENV CT_ALLOW_BUILD_AS_ROOT_SURE=y
WORKDIR /src

FROM crosstool AS sysroot

# 参数化架构
ARG ARCH=x86_64
ARG CONFIG_FILE=${ARCH}-gcc-8.5.0-glibc-2.28.config

COPY ${CONFIG_FILE} /src/.config
RUN ct-ng build

# 安装 patchelf 到 sysroot
RUN wget -O - https://github.com/NixOS/patchelf/releases/download/0.18.0/patchelf-0.18.0-${ARCH}.tar.gz \
    | tar zxv -C ${ARCH}-linux-gnu/${ARCH}-linux-gnu/sysroot/usr ./bin/patchelf

# 打包 sysroot
RUN tar zcf vscode-sysroot-${ARCH}-linux-gnu.tgz \
    -C ${ARCH}-linux-gnu/${ARCH}-linux-gnu --exclude '*.a' sysroot