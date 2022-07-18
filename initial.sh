#!/bin/bash

# Initial setup
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get update -y
sudo apt-get install -y \
  build-essential \
  zlib1g \
  zlib1g-dev \
  libbz2-dev \
  libncurses5-dev \
  libncursesw5-dev \
  libffi-dev \
  libreadline-dev \
  libssl-dev \
  openssl \
  libsqlite3-dev \
  lzma \
  lzma-dev \
  liblzma-dev \
  curl \
  wget \
  git \
  gcc \
  g++ \
  make \
  vim \
  direnv \
  unzip

# Installing Oh My Bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
