FROM ubuntu:latest

ARG UNAME=localdev
ARG UID=1000
ARG GID=1000

ENV LOCALDEV_USER=${UNAME}

USER root

RUN apt-get update && \
    apt-get -y install \
        apt-transport-https \
        bash \
        ca-certificates \
        curl \
        fd-find \
        git \
        gnupg \
        inotify-tools \
        iputils-ping \
        jq \
        libnss3-tools \
        lsb-release \
        openssl \
        python3-yaml \
        sudo \
        tree \
        vim

# Add all the repos
RUN export ARCH=$(dpkg --print-architecture) && \
    mkdir -p /etc/apt/keyrings && \
    \
    curl -fsSL 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xB1998361219BD9C9' | gpg --dearmor -o /etc/apt/keyrings/azul.gpg && \
    echo \
        "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/azul.gpg] https://repos.azul.com/zulu/deb stable main" \
        | tee /etc/apt/sources.list.d/zulu-openjdk.list > /dev/null && \
    \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo \
        "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
        | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update

RUN apt-get dist-upgrade -y && \
    apt-get -y install \
    containerd.io \
    docker-ce \
    docker-ce-cli \
    zulu11-jdk-headless \
    && apt-get clean

SHELL ["/bin/bash", "-c"]

# Install kubectl
RUN export ARCH=$(dpkg --print-architecture) && \
    curl -fsSL "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl" -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl

# Install k3d
RUN export TAG=$(curl -fsSL https://api.github.com/repos/k3d-io/k3d/releases/latest | jq -r '.name') && \
    curl -fsSL https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Install tilt
RUN export VERSION=$(curl -fsSL https://api.github.com/repos/tilt-dev/tilt/releases/latest | jq -r '.name') && \
    curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | sudo bash

# Install ytt
RUN export ARCH=$(dpkg --print-architecture) && \
    curl -fsSL https://github.com/vmware-tanzu/carvel-ytt/releases/latest/download/ytt-linux-${ARCH} -o /usr/local/bin/ytt && \
    chmod +x /usr/local/bin/ytt

# Install yq
RUN export ARCH=$(dpkg --print-architecture) && \
    curl -fsSL https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${ARCH} -o /usr/local/bin/yq && \
    chmod a+x /usr/local/bin/yq

RUN \
    groupadd -g $GID -o $UNAME && \
    useradd -d /home/$UNAME -g $GID -m -s /bin/bash -u $UID $UNAME && \
    echo "$UNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    \
    mkdir /workspace && \
    chown $UNAME:$UNAME /workspace

USER $UNAME

WORKDIR /workspace

COPY --chown=$UNAME:$UNAME entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]