FROM ghcr.io/calou-code-platform/ccp-base-ubuntu:main

LABEL maintainer="caloutw"
LABEL org.opencontainers.image.title="Remosh"
LABEL org.opencontainers.image.version="1.2.0"
LABEL org.opencontainers.image.authors="calou code platform"
LABEL org.opencontainers.image.description="[Remosh]A simple SSH environment for docker."

ENV username="linux"
ENV password="password"
ENV sudo_password="sudo_password"

USER root

RUN userdel -r ubuntu || true

RUN DEBIAN_FRONTEND=noninteractive apt update -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    curl \
    sudo \
    git \
    wget \
    software-properties-common \
    ca-certificates \
    gnupg \
    openssh-server \
    tmux \
    gcc &&\
    rm -rf /var/lib/apt/lists/*

RUN echo 'Defaults lecture="never"' >> /etc/sudoers
RUN rm -rf /etc/update-motd.d/* /etc/legal /usr/share/doc/base-files/README

COPY sshd_config /etc/ssh/sshd_config
COPY motd /etc/motd

RUN mkdir /cont
WORKDIR /cont

COPY get-builder.sh ./
RUN chmod 777 get-builder.sh

COPY init.sh ./
RUN chmod 777 init.sh

COPY .bashrc ./
COPY .bash_profile ./

COPY title ./

EXPOSE 22

CMD ["/cont/init.sh"]
