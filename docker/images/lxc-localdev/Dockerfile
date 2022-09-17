FROM ubuntu:latest

RUN apt-get update && \
    apt-get -y install bash \
    curl \
    git \
    jq \
    openssl \
    sudo \
    vim \
    wget

SHELL ["/bin/bash", "-c"]

# install docker
RUN curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

# Install k3d
RUN curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Install tilt
RUN curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash

# Install ytt
RUN wget -O- https://carvel.dev/install.sh | bash

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]