.PHONY: fibo_sp1 fibo_pico_10k_wrapped fibo_pico_100k_wrapped fibo_pico_4M_wrapped fibo_risc0

# PROOF_MODE ONLY USED FOR SP1
PROOF_MODE ?= compressed

# Iterations of fibonacci
N ?= 100000

build_pico_elf:
	cd fibo_pico/app && cargo pico build

build_pico:
	cd fibo_pico/prover && cargo build --release

build_sp1:
	cd fibo_sp1/script && cargo build --release

build_risc0:
	cd fibo_risc0/host && cargo build --release


fibo_pico_wrapped:
	./fibo_pico/target/release/prover $(N)

fibo_sp1:
	./fibo_sp1/target/release/fibonacci $(N) $(PROOF_MODE)

fibo_risc0:
	RUST_LOG=info RISC0_INFO=1 ./fibo_risc0/target/release/host $(N)
