FROM ghcr.io/calou-code-platform/ccp-base-ubuntu:main

LABEL maintainer="caloutw"
LABEL org.opencontainers.image.title="Remosh"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.authors="calou code platform"
LABEL org.opencontainers.image.description="[Remosh]A simple SSH environment for docker."

ENV username="linux"
ENV password="password"
ENV sudo_password="sudo_password"

USER root
RUN echo "root:$sudo_password" | chpasswd

RUN userdel -r ubuntu || true
RUN useradd -m -s /bin/bash -u 1000 $username
RUN echo "$username:$password" | chpasswd

RUN DEBIAN_FRONTEND=noninteractive apt update -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
    openssh-server \
    curl \
    sudo \
    git \
    wget \
    ca-certificates \
    gnupg &&\
    rm -rf /var/lib/apt/lists/*

RUN rm -rf /etc/update-motd.d/* /etc/legal /usr/share/doc/base-files/README

COPY sshd_config /etc/ssh/sshd_config
COPY motd /etc/motd

RUN mkdir /cont
WORKDIR /cont
COPY init.sh ./
COPY title ./
COPY builder.sh ./home/${username}/
RUN chmod 777 ./home/${username}/builder.sh

EXPOSE 22

CMD ["/cont/init.sh"]