.PHONY: build_elf_fibo_pico build_fibo_pico build_fibo_sp1 build_fibo_risc0
.PHONY: build_elf_keccak_pico build_keccak_pico build_keccak_sp1 build_keccak_risc0
.PHONY: fibo_pico_wrapped fibo_sp1 fibo_risc0
.PHONY: keccak_pico keccak_sp1 keccak_risc0
.PHONY: run_plotter create_python_venv install_requirements export_notebook

# PROOF_MODE ONLY USED FOR SP1
PROOF_MODE ?= compressed

# Iterations of fibonacci
N ?= 100000

# action_function_proving-system

# Pico is the only prover which doesn't
# build ELF elf automatically if it's no thee
build_elf_fibo_pico:
	cd fibo_pico/app && cargo pico build

build_elf_keccak_pico:
	cd keccak_pico/app && cargo pico build

build_fibo_pico:
	cd fibo_pico/prover && cargo build --release

build_keccak_pico:
	cd keccak_pico/prover && cargo build --release

build_fibo_sp1:
	cd fibo_sp1/script && cargo build --release

build_keccak_sp1:
	cd keccak_sp1/script && cargo build --release

build_fibo_risc0:
	cd fibo_risc0/host && cargo build --release

build_fibo_risc0_cuda:
	cd fibo_risc0/host && cargo build --release -F cuda

build_keccak_risc0:
	cd keccak_risc0/host && cargo build --release

build_keccak_risc0_cuda:
	cd keccak_risc0/host && cargo build --release -F cuda

fibo_pico_wrapped:
	./fibo_pico/target/release/prover $(N)

keccak_pico:
	./keccak_pico/target/release/prover $(N)

fibo_sp1:
	./fibo_sp1/target/release/fibonacci $(N) $(PROOF_MODE)

keccak_sp1:
	./keccak_sp1/target/release/prover $(N) $(PROOF_MODE)

fibo_risc0:
	RUST_LOG=info RISC0_INFO=1 ./fibo_risc0/target/release/host $(N)

fibo_risc0_cuda:
	RUSTFLAGS="-C target-cpu=native" RUST_LOG=info RISC0_INFO=1 ./fibo_risc0/target/release/host $(N)

keccak_risc0:
	RUST_LOG=info RISC0_INFO=1 RISC0_KECCAK_PO2=18 ./keccak_risc0/target/release/host $(N)

keccak_risc0_cuda:
	RUSTFLAGS="-C target-cpu=native" RUST_LOG=info RISC0_INFO=1 RISC0_KECCAK_PO2=18 ./keccak_risc0/target/release/host $(N)

run_plotter_fibo: INPUT_FILE=benchmark_fibo_results.csv
run_plotter_fibo: X_LABEL="Fibonacci N"
run_plotter_fibo: FUNCTION="Fibonacci"
run_plotter_fibo: run_plotter

run_plotter_keccak: INPUT_FILE=benchmark_keccak_results.csv
run_plotter_keccak: X_LABEL="Vec of Length N bytes"
run_plotter_keccak: FUNCTION="Keccak"
run_plotter_keccak: run_plotter

run_plotter:
	@echo "Running plotter..."
	@python3 plotter.py $(INPUT_FILE) $(X_LABEL) $(FUNCTION)

create_python_venv:
	@echo "Creating virtual environment..."
	@python3 -m venv venv
	@echo "Virtual environment created successfully on 'venv' directory!"

install_requirements:
	@echo "Installing dependencies..."
	@pip install -r requirements.txt

export_notebook:
	@echo "Exporting notebook to HTML..."
	@jupyter nbconvert --to html benchmark.ipynb --output index --HTMLExporter.theme=dark --no-input
	@sed -i '' 's/<title>.*<\/title>/<title>zkvms benchmarking<\/title>/' index.html
	@echo "Notebook exported successfully to 'index.html'!"
