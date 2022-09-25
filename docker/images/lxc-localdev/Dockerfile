FROM ubuntu:latest

RUN apt-get update && \
    apt-get -y install bash \
    curl \
    git \
    jq \
    yq \
    iputils-ping \
    openssl \
    sudo \
    vim \
    wget

RUN curl -H 'accept: */*' -L -s -X 'GET' -o /tmp/jdk11.deb "https://api.azul.com/zulu/download/community/v1.0/bundles/latest/binary/?arch=amd64&bundle_type=jdk&ext=deb&hw_bitness=64&java_version=11.0&javafx=false&os=linux&zulu_version=11.58.23" && \
	apt-get install --no-install-recommends --yes /tmp/jdk11.deb && \
	rm /tmp/jdk11.deb

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

RUN curl -fsSl https://raw.githubusercontent.com/liferay/liferay-blade-cli/master/cli/installers/global | bash

WORKDIR /workspace

# setup a workspace to build client-extensions with

# use latest available
RUN blade init -v dxp-7.4-u42

COPY workspace/build.gradle /workspace/build.gradle

#COPY workspace/configs /workspace/configs/

COPY workspace/gradle/ /workspace/gradle/

COPY workspace/gradle.properties /workspace/gradle.properties

# copy sample client extensions both test and warmup caches
COPY workspace/sample-client-extensions /workspace/sample-client-extensions

COPY workspace/settings.gradle /workspace/settings.gradle

# custom workspace plugin
COPY workspace/temp_repo /workspace/temp_repo

# warm up the caches
RUN ./gradlew build

# remove samples
RUN rm -rf /workspace/sample-client-extensions

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]