ARG OS

FROM $OS

ENV SWIFT_GIT_URL="https://github.com/apple/swift.git"
ENV SWIFT_RELEASE_VERSION="release/5.3"
ENV SOURCE_DIR="/root/source"
ENV DEBCONF_NONINTERACTIVE_SEEN=true
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -q update

RUN apt-get install -y    \
    clang                 \
    cmake                 \
    git                   \
    icu-devtools          \
    libcurl4-openssl-dev  \
    libedit-dev           \
    libicu-dev            \
    libncurses5-dev       \
    libpython3-dev        \
    libsqlite3-dev        \
    libxml2-dev           \
    ninja-build           \
    pkg-config            \
    python                \
    python-six            \
    python3-sphinx        \
    rsync                 \
    swig                  \
    systemtap-sdt-dev     \
    tzdata                \
    uuid-dev

RUN mkdir -p $SOURCE_DIR

WORKDIR $SOURCE_DIR

RUN git config --global pack.threads "0"

RUN git clone $SWIFT_GIT_URL

WORKDIR $SOURCE_DIR/swift

RUN git checkout $SWIFT_RELEASE_VERSION

WORKDIR $SOURCE_DIR

RUN ./swift/utils/update-checkout --clone

RUN ./swift/utils/build-toolchain --release

RUN ./swift/utils/build-toolchain --release --test

ARG ARCH

WORKDIR /

RUN tar xvf /root/source/swift*tar.gz

RUN rm -fr /root/source

RUN swift build --version
