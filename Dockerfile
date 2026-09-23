FROM ghcr.io/calou-code-platform/ccp-base-debian:main

LABEL maintainer="caloutw"
LABEL org.opencontainers.image.title="Remosh"
LABEL org.opencontainers.image.version="3.0.0"
LABEL org.opencontainers.image.authors="calou code platform"
LABEL org.opencontainers.image.description="[Remosh] A simple SSH environment for docker."

ENV password="password"
ENV cloudflared=""

USER root

RUN export DEBIAN_FRONTEND=noninteractive

# 安裝必要項目
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    curl \
    sudo \
    git \
    wget \
    ca-certificates \
    gnupg \
    openssh-server \
    tmux \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 移除進入警告
RUN echo 'Defaults lecture="never"' >> /etc/sudoers
RUN rm -rf /etc/update-motd.d/* /etc/legal /usr/share/doc/base-files/README

# 創建 sshd 實例
RUN mkdir -p /run/sshd
RUN mkdir -p --mode=0755 /usr/share/keyrings

# 修改 sshd 的設定檔
COPY sshd/sshd_config /etc/ssh/sshd_config
COPY sshd/motd /etc/motd

# 建立 root 的 workspace
RUN mkdir -p /root/workspace

# 建立工作區域
RUN mkdir /ccp
WORKDIR /ccp

# 複製工具
COPY get-builder.sh ./
RUN chmod +x get-builder.sh

COPY .bashrc ./
COPY .bash_profile ./

COPY run.sh ./
RUN chmod +x run.sh

COPY title ./

EXPOSE 22
CMD ["/ccp/run.sh"]