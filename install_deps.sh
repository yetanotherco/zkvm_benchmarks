#!/bin/bash

# Exit on error
set -e

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "Cannot detect OS"
    exit 1
fi

echo "Installing system dependencies and Docker..."

# Configure debconf to be noninteractive
sudo dpkg-reconfigure debconf --frontend=noninteractive

# Install system dependencies
sudo apt-get update
sudo apt-get install -y gcc pkg-config libssl-dev build-essential \
    apt-transport-https ca-certificates curl software-properties-common

# Set up Docker repository
sudo install -m 0755 -d /etc/apt/keyrings

# Download and set up Docker's GPG key
sudo curl -fsSL https://download.docker.com/linux/${OS}/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to apt sources
case $OS in
    ubuntu)
        echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        ;;
    debian)
        echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Update package list and install Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Set up Docker group
sudo groupadd docker || true
sudo usermod -aG docker $USER
sudo systemctl restart docker

echo "Installing Rust..."

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
export PATH="$HOME/.cargo/bin:$PATH"
. "$HOME/.cargo/env"

# Setup Rust toolchain
rustup toolchain install nightly
rustup component add rust-src --toolchain nightly-2024-11-27-x86_64-unknown-linux-gnu

echo "Installing additional tools..."

# Install SP1
curl -L https://sp1.succinct.xyz | bash
source "$HOME/.bashrc"
sp1up

# Install RISC Zero
curl -L https://risczero.com/install | bash
. "$HOME/.bashrc"
rzup install

# Install Pico CLI
cargo +nightly install --git https://github.com/brevis-network/pico pico-cli

echo "Installation complete! Please run 'newgrp docker' or log out and back in to use Docker without sudo."
