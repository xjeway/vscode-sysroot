FROM ubuntu:latest AS crosstool

# 安装构建依赖
RUN apt-get update && apt-get install -y \
    gcc g++ gperf bison flex texinfo help2man make libncurses5-dev \
    python3-dev autoconf automake libtool libtool-bin gawk wget bzip2 xz-utils unzip \
    patch rsync meson ninja-build \
    && rm -rf /var/lib/apt/lists/*

# 安装 crosstool-ng
ENV PKG=crosstool-ng-1.27.0
RUN wget https://github.com/crosstool-ng/crosstool-ng/releases/download/$PKG/$PKG.tar.bz2 \
    && tar -xjf $PKG.tar.bz2 \
    && cd $PKG && ./configure --prefix=/usr/local && make && make install \
    && cd .. && rm -rf $PKG.tar.bz2 $PKG

ENV CT_ALLOW_BUILD_AS_ROOT_SURE=y
WORKDIR /src

FROM crosstool AS sysroot

# 继承crosstool阶段的环境变量
ENV CT_ALLOW_BUILD_AS_ROOT_SURE=y

# 参数化架构
ARG ARCH=x86_64
ARG CONFIG_FILE=${ARCH}-gcc-8.5.0-glibc-2.28.config
ARG PREFIX_DIR=vendor/vscode-linux-build-agent/

# 复制配置文件
COPY ${PREFIX_DIR}${CONFIG_FILE} /src/.config

# 构建工具链
RUN ct-ng build

# 安装 patchelf 到 sysroot
RUN case ${ARCH} in \
        x86_64) \
            wget -O - https://github.com/NixOS/patchelf/releases/download/0.18.0/patchelf-0.18.0-x86_64.tar.gz | tar zxv -C ${ARCH}-linux-gnu/${ARCH}-linux-gnu/sysroot/usr ./bin/patchelf ;; \
        aarch64) \
            wget -O - https://github.com/NixOS/patchelf/releases/download/0.18.0/patchelf-0.18.0-aarch64.tar.gz | tar zxv -C ${ARCH}-linux-gnu/${ARCH}-linux-gnu/sysroot/usr ./bin/patchelf ;; \
        armhf) \
            wget -O - https://github.com/NixOS/patchelf/releases/download/0.18.0/patchelf-0.18.0-armhf.tar.gz | tar zxv -C ${ARCH}-linux-gnu/${ARCH}-linux-gnu/sysroot/usr ./bin/patchelf ;; \
    esac

# 打包 sysroot，排除静态库以减小体积
RUN tar zcf vscode-sysroot-${ARCH}-linux-gnu.tgz \
    -C ${ARCH}-linux-gnu/${ARCH}-linux-gnu --exclude '*.a' sysroot

# 显示构建信息
RUN echo "Built sysroot for architecture: ${ARCH}" && \
    ls -la vscode-sysroot-${ARCH}-linux-gnu.tgz