#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=${DEBIAN_FRONTEND:-noninteractive}

apt-get update
apt-get install -y --no-install-recommends \
  apt-transport-https \
  bash \
  bat \
  build-essential \
  ca-certificates \
  curl \
  delta \
  direnv \
  eza \
  fd-find \
  fontconfig \
  fzf \
  git \
  gnupg \
  htop \
  jq \
  just \
  less \
  locales \
  nano \
  openssh-client \
  openssh-server \
  pkg-config \
  procps \
  ripgrep \
  rsync \
  software-properties-common \
  sudo \
  tmux \
  tree \
  tzdata \
  unzip \
  vim \
  wget \
  xclip \
  yq \
  zip \
  zoxide \
  zsh

locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
ln -sf /usr/bin/fdfind /usr/local/bin/fd
if command -v batcat >/dev/null 2>&1; then
  ln -sf "$(command -v batcat)" /usr/local/bin/bat
fi
