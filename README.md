# zkVMs benchmarks

## Preeliminary results for Fibonacci

### M3 GPU (10 cores, 36 GiB), n=10k

| System | Time Avg [s] | Time Min [s] | Time Max [s] | Proof size | Individual Time Measurements [s] |
|--------|-------------|--------------|--------------|------------|--------------------------------|
| SP1 (Compressed) | 51 | 49 | 55 | 1.3M | 49, 51, 55, 48.6, 49 |
| SP1 (Groth16 compressed) | Fails | Fails | Fails | - | - |
| Pico (Gnark compressed) | Fails | Fails | Fails | - | - |

### Intel Xeon Gold 6226R (16 cores), n=10k

| Implementation | Time Avg [h:m:s] | Time Min [h:m:s] | Time Max [h:m:s] | Proof size | Individual Time Measurements |
|----------------|------------------|------------------|------------------|------------|----------------------------|
| SP1 (Compressed, no avx) | 0:01:46 | 0:01:46 | 0:01:46 | 1.3M | 0:01:46 |
| SP1 (Groth16 compressed, no avx) | 0:05:06 | 0:04:58 | 0:05:16 | 1.4K | 0:05:04, 0:05:16, 0:04:58 |
| SP1 (Compressed, avx) | 0:01:17 | 0:01:16 | 0:01:17 | 1.3M | 0:01:16, 0:01:17, 0:01:17 |
| SP1 (Gnark compressed, avx) | 0:04:19 | 0:04:18 | 0:04:20 | 1.4K | 0:04:20, 0:04:18, 0:04:19 |
| Pico (Gnark compressed) | 6:00:49 | 0:01:02 | 0:00:00 | 893K | 0:01:02, 0:01:06, 0:01:08 |

### Intel Xeon Gold 6226R (16 cores), n=4M

| Implementation | Time Avg [h:m:s] | Time Min [h:m:s] | Time Max [h:m:s] | Proof size |
|----------------|------------------|------------------|------------------|------------|
| SP1 (Compressed, no avx) | - | - | - | - |
| SP1 (Groth16 compressed, no avx) | 0:40:21 | 0:40:21 | 0:40:21 | - |
| SP1 (Compressed, avx) | - | - | - | - |
| SP1 (Gnark compressed, avx) | 0:28:37 | 0:28:37 | 0:28:37 | - |
| Pico (Gnark compressed) | 0:43:16 | 0:43:16 | 0:43:16 | - |

## Requirements

- risc0
- sp1
- pico
- Docker (For SP1 groth16 compression)

## Commands


To run the benchmark, first do a run with small programs to see if everything is working:

```TEST_MODE=1 bash benchmark.sh```

First run will also download SP1 docker image for groth16 compression, so the values for that bench may be off on this first run.

After making sure it work, you can run:

```bash benchmark.sh```

If you want to force SP1 to get the images, prove a small program with:

```PROOF_MODE=groth16 N=5 make fibo_sp1```

In ubuntu, you can install everything you need with:

```sh
# Install system dependencies and Docker
sudo apt-get update
sudo apt-get install -y gcc pkg-config libssl-dev build-essential apt-transport-https ca-certificates curl software-properties-common
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo groupadd docker || true
sudo usermod -aG docker $USER

# Install and setup Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
export PATH="$HOME/.cargo/bin:$PATH"
. "$HOME/.cargo/env"
rustup toolchain install nightly
rustup component add rust-src --toolchain nightly-2024-11-27-x86_64-unknown-linux-gnu

# Install remaining tools
curl -L https://sp1.succinct.xyz | bash
source "$HOME/.bashrc"
sp1up
curl -L https://risczero.com/install | bash
. "$HOME/.bashrc"
rzup install
cargo +nightly install --git https://github.com/brevis-network/pico pico-cli

echo "Installation complete! Please run 'newgrp docker' or log out and back in to use Docker without sudo."
```
