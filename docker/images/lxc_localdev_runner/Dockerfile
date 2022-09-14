FROM alpine:3.16.0 as lxc-localdev

RUN apk add --no-cache \
    bash \
    curl \
    docker \
    git \
    jq \ 
    openssl \
    shadow \
    vim \
    wget \
    yq

RUN groupadd -r localdev \
             -g 777 && \
    useradd -c "localdev account" \
            -g localdev \
            -u 777 \
            -m \
            -r \
            localdev && \
    usermod -aG docker localdev

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

# Install Kubernetes in Docker (kind)
RUN curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.13.0/kind-linux-amd64 && \
  chmod +x ./kind && \
  mv ./kind /usr/local/bin/kind

# Install helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
  chmod 700 get_helm.sh && \
  ./get_helm.sh

COPY localdev_runner /
COPY kind-cluster.yaml /root/

ENTRYPOINT [ "/bin/bash", "/localdev_runner" ]