FROM ghcr.io/calou-code-platform/ccp-base-debian:main

LABEL maintainer="caloutw"
LABEL org.opencontainers.image.title="Remosh"
LABEL org.opencontainers.image.version="2.0.0"
LABEL org.opencontainers.image.authors="calou code platform"
LABEL org.opencontainers.image.description="[Remosh]A simple SSH environment for docker."

ENV username="linux"
ENV password="password"
ENV sudo_password="sudo_password"
ENV cloudflared=""

USER root

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
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
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo 'Defaults lecture="never"' >> /etc/sudoers
RUN rm -rf /etc/update-motd.d/* /etc/legal /usr/share/doc/base-files/README

RUN mkdir -p /run/sshd
RUN mkdir -p --mode=0755 /usr/share/keyrings

COPY config/sshd_config /etc/ssh/sshd_config
COPY config/motd /etc/motd

RUN mkdir /spc
WORKDIR /spc

COPY tools/get-builder.sh ./
RUN chmod +x get-builder.sh

COPY run.sh ./
RUN chmod +x run.sh

COPY config/.bashrc ./
COPY config/.bash_profile ./

RUN cp .bashrc /home/${username}/.bashrc && \
    cp .bash_profile /home/${username}/.bash_profile && \
    cp get-builder.sh /home/${username}/get-builder.sh && \
    chown ${username}:${username} /home/${username}/.bashrc /home/${username}/.bash_profile /home/${username}/get-builder.sh

COPY server/title ./

EXPOSE 22

CMD ["/spc/run.sh"]
