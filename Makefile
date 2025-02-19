.PHONY: fibo_sp1 fibo_pico fibo_risc0 build_pico build_sp1 build_risc0 build_pico_elf build_keccak_sp1 build_keccak_pico keccak_pico keccak_sp1 run_plotter create_python_venv

# PROOF_MODE ONLY USED FOR SP1
PROOF_MODE ?= compressed

# Iterations of fibonacci
N ?= 100000

# Pico is the only prover which doesn't
# build ELF elf automatically if it's no thee
build_pico_elf:
	cd fibo_pico/app && cargo pico build

build_pico_keccak_elf:
	cd keccak_pico/app && cargo pico build

build_pico_rsp_elf:
	cd keccak_pico/app && cargo pico build

build_keccak_pico:
	cd keccak_pico/prover && cargo build --release

build_pico:
	cd fibo_pico/prover && cargo build --release

build_sp1:
	cd fibo_sp1/script && cargo build --release

build_keccak_sp1:
	cd keccak_sp1/script && cargo build --release

build_rsp:
	cd rsp_sp1/script && cargo build --release

build_fibo_risc0:
	cd fibo_risc0/host && cargo build --release

keccak_pico:
	./keccak_pico/target/release/prover $(N)

fibo_pico_wrapped:
	./fibo_pico/target/release/prover $(N)

fibo_sp1:
	./fibo_sp1/target/release/fibonacci $(N) $(PROOF_MODE)

keccak_sp1:
	./keccak_sp1/target/release/prover $(N)

rsp_sp1:
	./keccak_sp1/target/release/prover --prove

fibo_risc0:
	RUST_LOG=info RISC0_INFO=1 ./fibo_risc0/target/release/host $(N)

run_plotter: create_python_venv install_requirements
	@echo "Running plotter..."
	@. venv/bin/activate && python3 plotter.py $(INPUT_FILE)

create_python_venv:
	@echo "Creating virtual environment..."
	@python3 -m venv venv
	@echo "Virtual environment created successfully!"

install_requirements:
	@echo "Installing dependencies..."
	@. venv/bin/activate && pip install -r requirements.txt
