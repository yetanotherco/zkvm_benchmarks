.PHONY: fibo_sp1 fibo_pico_10k_wrapped fibo_pico_100k_wrapped fibo_pico_4M_wrapped fibo_risc0

build_pico:
	cd fibo_pico/app && cargo pico build

fibo_pico_wrapped:
	 cd fibo_pico/app && cargo pico prove --input `python3 ../n_to_pico_hex.py $(N)` && cd ..

fibo_pico_100k_wrapped:
	cd fibo_pico/app && RUST_LOG=info cargo pico prove --input "0xA0860100" && cd ..

fibo_pico_4M_wrapped:
	cd fibo_pico/app && RUST_LOG=info cargo pico prove --input "0x00093D00" && cd ..


PROOF_MODE ?= groth16

# Default values if not specified
PROOF_MODE ?= groth16
N ?= 100000

fibo_sp1:
	cd fibo_sp1/script && cargo run --release -- $(N) $(PROOF_MODE)

fibo_risc0:
	cd fibo_risc0/host && RUST_LOG=info RISC0_INFO=1 cargo run --release -- $(N)
