FROM ubuntu:latest

RUN apt-get update && \
    apt-get -y install \
        apt-transport-https \
        bash \
        ca-certificates \
        curl \
        git \
        gnupg \
        iputils-ping \
        jq \
        lsb-release \
        openssl \
        sudo \
        vim \
        wget

# Add all the repos
RUN mkdir -p /etc/apt/keyrings && \
    \
    curl -fsSL 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xB1998361219BD9C9' | gpg --dearmor -o /etc/apt/keyrings/azul.gpg && \
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/azul.gpg] https://repos.azul.com/zulu/deb stable main" \
        | tee /etc/apt/sources.list.d/zulu-openjdk.list > /dev/null && \
    \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
        | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    \
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg -o /etc/apt/keyrings/kubernetes.gpg && \
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/kubernetes.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" \
        | tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

RUN apt-get update

RUN apt-get dist-upgrade -y && \
    apt-get -y install \
    containerd.io \
    docker-ce \
    docker-ce-cli \
    kubectl \
    zulu11-jdk \
    && apt-get clean

SHELL ["/bin/bash", "-c"]

# Install k3d
RUN curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Install tilt
RUN curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | sudo bash

# Install ytt
RUN export ARCH=$(dpkg --print-architecture) && \
    export YTT_VERSION=$(curl -fsSL https://api.github.com/repos/vmware-tanzu/carvel-ytt/releases/latest | jq -r '.name') && \
    wget -q https://github.com/vmware-tanzu/carvel-ytt/releases/download/${YTT_VERSION}/checksums.txt && \
    wget -q https://github.com/vmware-tanzu/carvel-ytt/releases/download/${YTT_VERSION}/ytt-linux-$ARCH && \
    export YTTSUM=$(shasum -a 256 ytt-linux-$ARCH) && \
    export CHECKSUM=$(grep ytt-linux-$ARCH checksums.txt) && \
    [ "$YTTSUM" = "$CHECKSUM" ] && \
    mv ytt-linux-$ARCH /usr/local/bin/ytt && \
    chmod +x /usr/local/bin/ytt

# Install yq
RUN wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && chmod a+x /usr/local/bin/yq

# Install blade
RUN curl -fsSl https://raw.githubusercontent.com/liferay/liferay-blade-cli/master/cli/installers/global | bash

WORKDIR /workspace

# setup a workspace to build client-extensions with

# use latest available
RUN blade init -v dxp-7.4-u42

# these commands are sorted from least likely to most likely to change to better cache layers
COPY workspace/gradle/ /workspace/gradle/

COPY workspace/gradlew /workspace/gradlew

COPY workspace/settings.gradle /workspace/settings.gradle

COPY workspace/gradle.properties /workspace/gradle.properties

# custom workspace plugin
COPY workspace/temp_repo /workspace/temp_repo

COPY workspace/build.gradle /workspace/build.gradle

COPY entrypoint.sh /entrypoint.sh

COPY ca.crt /usr/local/share/ca-certificates/localdev.me.crt

RUN update-ca-certificates

ENTRYPOINT [ "/entrypoint.sh" ]
