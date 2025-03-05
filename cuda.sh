#!/bin/bash

## GCC needs to match coda version, 9.0 or 10.0 may be needed, 11 may not work

sudo apt-get update
sudo apt install gcc pkg-config libssl-dev build-essential apt-transport-https ca-certificates curl software-properties-common

# DOCKER

# Add Docker's official GPG key:

sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:

echo \
 "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
 $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
 sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# USER DOCKER

sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker


#CUDA
# Install x

wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb
sudo dpkg -i cuda-keyring_1.0-1_all.deb
sudo apt-get update
sudo apt-get install cuda
export PATH=/usr/local/cuda/bin${PATH:+:${PATH}} export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
source ~/.bashrc

sudo apt-get install nvidia-cuda-toolkit

# This may be needed for risc0:
export CUDA_HOME=/usr/local/cuda
export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH

sudo apt install gcc-9 g++-9

export CC=/usr/bin/gcc-9 export CXX=/usr/bin/g++-9
export CPATH=/usr/local/cuda/include:$CPATH export LIBRARY_PATH=/usr/local/cuda/lib64:$LIBRARY_PATH


# Docker cuda

# #Add NVIDIA Container Toolkit repository
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update

sudo apt-get install -y nvidia-container-toolkit

sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

##Test
docker run --gpus all --rm debian:stretch nvidia-smi

#RUST

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
. "$HOME/.cargo/env"

#PROVERS
curl -L https://sp1.succinct.xyz | bash
source /home/paperspace/.bashrc
sp1up

curl -L https://risczero.com/install | bash
. "/home/paperspace/.bashrc"
rzup install

# We are using risc0 v1.2.4
rzup install r0vm 1.2.4