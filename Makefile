.PHONY: fibo_sp1 fibo_pico_10k_wrapped fibo_pico_100k_wrapped fibo_pico_4M_wrapped fibo_risc0

# PROOF_MODE ONLY USED FOR SP1
PROOF_MODE ?= groth16

# Iterations of fibonacci
N ?= 100000

build_pico:
	cd fibo_pico/app && cargo pico build

build_sp1:
	cd fibo_sp1/script && cargo build --release

build_risc0:
	cd fibo_risc0/host && cargo build --release


fibo_pico_wrapped:
	 cd fibo_pico/app && RUST_LOG=info cargo pico prove --input `python3 ../n_to_pico_hex.py $(N)` && cd ..

fibo_sp1:
	cd fibo_sp1/script && cargo run --release -- $(N) $(PROOF_MODE)

fibo_risc0:
	cd fibo_risc0/host && RUST_LOG=info RISC0_INFO=1 ./target/release/fibo_risc0 -- $(N)
