# syntax=docker/dockerfile:1
FROM ubuntu:24.04 AS base

## set as non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive

## set time zone env var
ENV TZ=Asia/Taipei

## update system
RUN apt-get update && apt-get upgrade -y

## install bash and python
RUN apt-get install -y bash && apt-get install -y python3 python3-pip

## set default shell as bash
CMD ["/bin/bash"]

## create UID/GID for non-root user
ARG USERNAME=myuser
ARG UID=1001
ARG GID=1001

RUN groupadd --gid $GID $USERNAME && \
    useradd --uid $UID --gid $GID --create-home --shell /bin/bash $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

## switch to non-root user
USER $USERNAME

## set default working directory
WORKDIR /home/$USERNAME

# stage common_pkg_provider
FROM base AS common_pkg_provider

## switch to root
USER root

## install vim, git and pip
RUN apt-get install -y vim git curl wget ca-certificates build-essential python3 python3-pip && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

## install conda according to cpu's ISA
ARG CONDA_DIR=/opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH

RUN apt-get update && apt-get install -y bzip2 && \
    ARCH=$(uname -m) && \
    case "$ARCH" in \
      x86_64)  URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh ;; \
      aarch64) URL=https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh ;; \
      *)       echo "Unsupported arch $ARCH" && exit 1 ;; \
    esac && \
    curl -fsSL $URL -o miniconda.sh && \
    bash miniconda.sh -b -p $CONDA_DIR && \
    rm miniconda.sh && \
    ln -s $CONDA_DIR/etc/profile.d/conda.sh /etc/profile.d/conda.sh

USER $USERNAME

# stage verilator_provider
FROM base AS verilator_provider

USER root

RUN apt-get update && apt-get install -y \
    make autoconf g++ flex bison help2man && \
    git clone https://github.com/verilator/verilator.git && \
    cd verilator && \
    git checkout stable && \
    autoconf && ./configure && make -j$(nproc) && make install && \
    rm -rf /var/lib/apt/lists/*

USER $USERNAME

# stage systemc_provider
FROM base AS systemc_provider

USER root

RUN apt-get update && apt-get install -y wget tar autoconf automake libtool && \
    wget https://github.com/accellera-official/systemc/archive/refs/tags/2.3.4.tar.gz && \
    tar -xzf 2.3.4.tar.gz && \
    cd systemc-2.3.4 && \
    mkdir objdir && autoreconf -i && cd objdir && \
    ../configure --prefix=/opt/systemc-2.3.4 && \
    make -j$(nproc) && make install

ENV SYSTEMC_HOME=/opt/systemc-2.3.4

USER $USERNAME