.PHONY: fibo_sp1 fibo_pico_10k_wrapped fibo_pico_100k_wrapped fibo_pico_4M_wrapped fibo_risc0

# PROOF_MODE ONLY USED FOR SP1
PROOF_MODE ?= compressed

# Iterations of fibonacci
N ?= 100000

build_fibo_pico:
	cd fibo_pico/app && cargo pico build

build_fibo_sp1:
	cd fibo_sp1/script && cargo build --release

build_fibo_risc0:
	cd fibo_risc0/host && cargo build --release


fibo_pico_wrapped:
	 cd fibo_pico/app && RUST_LOG=info cargo pico prove --input `python3 ../n_to_pico_hex.py $(N)` && cd ..

fibo_sp1:
	./fibo_sp1/target/release/fibonacci $(N) $(PROOF_MODE)

fibo_risc0:
	RUST_LOG=info RISC0_INFO=1 ./fibo_risc0/target/release/host $(N)
