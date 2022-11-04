FROM ubuntu:latest

ARG UNAME=localdev
ARG UID=1000
ARG GID=1000
ARG DOCKER_GID=999

USER root

RUN apt-get update && \
    apt-get -y install \
        apt-transport-https \
        bash \
        ca-certificates \
        curl \
        git \
        gnupg \
        inotify-tools \
        iputils-ping \
        jq \
        libnss3-tools \
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
        | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update

RUN apt-get dist-upgrade -y && \
    apt-get -y install \
    containerd.io \
    docker-ce \
    docker-ce-cli \
    zulu11-jdk \
    && apt-get clean

SHELL ["/bin/bash", "-c"]

# Install kubectl
RUN export ARCH=$(dpkg --print-architecture) && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl" && \
    curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl.sha256" && \
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check && \
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install k3d
RUN export TAG=$(curl -fsSL https://api.github.com/repos/k3d-io/k3d/releases/latest | jq -r '.name') && \
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Install tilt
RUN export VERSION=$(curl -fsSL https://api.github.com/repos/tilt-dev/tilt/releases/latest | jq -r '.name') && \
    curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | sudo bash

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
RUN export ARCH=$(dpkg --print-architecture) && \
    wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_$ARCH && \
    chmod a+x /usr/local/bin/yq

# Install blade
RUN curl -fsSl https://raw.githubusercontent.com/liferay/liferay-blade-cli/master/cli/installers/global | bash

RUN \
    groupmod -g $DOCKER_GID docker && \
    groupadd -g $GID -o $UNAME && \
    useradd -d /home/$UNAME -g $GID -m -s /bin/bash -u $UID $UNAME && \
    mkdir /workspace && \
    chown $UNAME:$UNAME /workspace

USER $UNAME

WORKDIR /workspace

# setup a workspace to build client-extensions with

# use latest available
RUN blade init -v dxp-7.4-u47

# these commands are sorted from least likely to most likely to change to better cache layers
COPY --chown=$UNAME:$UNAME workspace/gradle/ /workspace/gradle/

COPY --chown=$UNAME:$UNAME workspace/gradlew /workspace/gradlew

COPY --chown=$UNAME:$UNAME workspace/settings.gradle /workspace/settings.gradle

COPY --chown=$UNAME:$UNAME workspace/gradle.properties /workspace/gradle.properties

COPY --chown=$UNAME:$UNAME workspace/build.gradle /workspace/build.gradle

# warm up gradle & yarn install
RUN /workspace/gradlew --no-daemon :yarnInstall

COPY --chown=$UNAME:$UNAME entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]