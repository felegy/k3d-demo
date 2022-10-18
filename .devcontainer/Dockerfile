# [Choice] Debian version (use bullseye on local arm64/Apple Silicon): bullseye, buster
ARG VARIANT=bullseye
ARG KUBE_CTL_VERSION
ARG K9S_VERSION
FROM mcr.microsoft.com/vscode/devcontainers/base:${VARIANT}
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND noninteractive
ARG VARIANT
ARG KUBE_CTL_VERSION
ARG K9S_VERSION
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN \
apt-get update; \
    apt-get install -y --no-install-recommends \
    apt-utils \
    software-properties-common \
    build-essential \
    bash-completion \
    binutils \
    tmux \
    jq \
    git \
    python3 \
    python3-dev \
    python3-pip; \
rm -rf /var/lib/apt/lists/*

RUN \
pip3 install --upgrade \
    setuptools \
    pip

ADD requirements.txt /requirements.txt

RUN pip3 install --upgrade -r /requirements.txt

ADD "https://dl.k8s.io/release/${KUBE_CTL_VERSION}/bin/linux/amd64/kubectl" /tmp/
ADD "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_x86_64.tar.gz" /tmp

RUN \
chmod a+x /tmp/kubectl; \
mv /tmp/kubectl /usr/local/bin; \
(cd /tmp; tar zxf k9s_*.tar.gz; mv k9s /usr/local/bin); \
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash; \
curl -fsSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64; \
chmod +x /usr/local/bin/argocd; \
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -; \
add-apt-repository "deb https://download.docker.com/linux/debian/ ${VARIANT} stable"; \
apt-get update -qq; \
apt-get install docker-ce-cli; \
ln -s /usr/bin/python3 /usr/bin/python; \
#
# Clean up
apt-get autoremove; \
apt-get clean; \
rm -rf /var/lib/apt/lists/*

USER vscode
RUN \
mkdir -p $HOME/.ssh && chmod 700 $HOME/.ssh; \
echo 'Host github.com \n\
  Hostname ssh.github.com \n\
  Port 443 \n\
  User git \n\
\n\
Host gist.github.com \n\
  Hostname ssh.github.com \n\
  Port 443 \n\
  User git \n\
'>  $HOME/.ssh/config; \
echo 'source <(kubectl completion bash)' >> ~/.bashrc; \
echo 'source <(kubectl completion zsh)' >> ~/.zshrc; \
echo 'source <(helm completion bash)' >> ~/.bashrc; \
echo 'source <(helm completion zsh)' >> ~/.zshrc;
USER root
