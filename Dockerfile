ARG JENKINS_VERSION=latest
FROM jenkins/jenkins:$JENKINS_VERSION

LABEL org.opencontainers.image.authors="contact@ethersys.fr"
LABEL org.opencontainers.image.source="https://github.com/ethersys/ethersys-docker-jenkins"
LABEL org.opencontainers.image.description="Official Jenkins LTS image with Docker binaries"

USER root

RUN install -m 0755 -d /etc/apt/keyrings

RUN apt-get update \
    && apt-get install -y \
          sudo \
          software-properties-common \
          apt-transport-https \
    && curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update \
    && apt-get install -y \
          make \
          rsync \
          ruby \
          docker-ce \
          dnsutils \
    && rm -rf /var/lib/apt/lists/* \
    && echo 'jenkins ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

RUN echo "alias docker-compose=\"docker compose\"" >> /etc/bash.bashrc
RUN printf "#!/bin/sh\nexec docker compose \"\$@\"\n" > /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

RUN usermod -a -G docker jenkins
RUN usermod -a -G 996 jenkins
RUN usermod -a -G 999 jenkins

USER jenkins
