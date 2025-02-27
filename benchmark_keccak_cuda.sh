#!/bin/bash

format_time() {
    local seconds=$1
    if (( $(echo "$seconds >= 60" | bc -l) )); then
        local minutes=$(echo "$seconds / 60" | bc)
        local remaining_seconds=$(echo "$seconds - ($minutes * 60)" | bc)
        if (( $(echo "$remaining_seconds == ${remaining_seconds%.*}" | bc -l) )); then
            printf "%dm%ds" $minutes ${remaining_seconds%.*}
        else
            printf "%dm%.1fs" $minutes $remaining_seconds
        fi
    else
        if (( $(echo "$seconds == ${seconds%.*}" | bc -l) )); then
            printf "%ds" ${seconds%.*}
        else
            printf "%.1fs" $seconds
        fi
    fi
}

if [ -n "$TEST_MODE" ]; then
    echo "Running in test mode"
    N_VALUES=(32)
else
    N_VALUES=(32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152 4194304 8388608) # ~ 10KB 100KB 1MB
fi

OUTPUT_FILE="benchmark_keccak_cuda_results.csv"

# Detect CPU capabilities and set SP1 configuration
if grep -q "avx512" /proc/cpuinfo; then
    SP1_RUSTFLAGS="-C target-cpu=native -C target-feature=+avx512f"
    SP1_NAME="SP1-AVX512"
elif grep -q "avx2" /proc/cpuinfo; then
    SP1_RUSTFLAGS="-C target-cpu=native"
    SP1_NAME="SP1-AVX2"
else
    SP1_RUSTFLAGS=""
    SP1_NAME="SP1-Base"
fi

# Build all projects
echo "Building all projects..."
#make build_keccak_sp1 RUSTFLAGS="$SP1_RUSTFLAGS"
#make build_keccak_pico
make build_keccak_risc0_cuda

# Initialize results file
echo "Prover,N,Time" > $OUTPUT_FILE

for n in "${N_VALUES[@]}"; do
    # Pico benchmark
#    echo "Running Pico with N=$n"
#    start=$(date +%s.%N)
#    make keccak_pico N=$n > /dev/null 2>&1
#    end=$(date +%s.%N)
#    time=$(echo "$end - $start" | bc)
#    echo "Pico Groth16,$n,$(format_time $time)" >> $OUTPUT_FILE

    # SP1 Compressed benchmark
#    echo "Running SP1 (Compressed) with N=$n"
#    start=$(date +%s.%N)
#    make keccak_sp1 N=$n PROOF_MODE=compressed RUSTFLAGS="$SP1_RUSTFLAGS" > /dev/null 2>&1
#    end=$(date +%s.%N)
#    time=$(echo "$end - $start" | bc)
#    echo "$SP1_NAME,$n,$(format_time $time)" >> $OUTPUT_FILE

    # SP1 Groth16 benchmark (Linux + Docker only)
#    if [[ "$(uname)" == "Linux" ]] && command -v docker >/dev/null 2>&1; then
#        echo "Running SP1 (Groth16) with N=$n"
#        start=$(date +%s.%N)
#        make keccak_sp1 N=$n PROOF_MODE=groth16 RUSTFLAGS="$SP1_RUSTFLAGS" > /dev/null 2>&1
#        end=$(date +%s.%N)
#        time=$(echo "$end - $start" | bc)
#        echo "$SP1_NAME-Groth16,$n,$(format_time $time)" >> $OUTPUT_FILE
#    fi

    # RISC0 benchmark
    echo "Running RISC0 with N=$n"
    start=$(date +%s.%N)
    make keccak_risc0_cuda N=$n > /dev/null 2>&1
    end=$(date +%s.%N)
    time=$(echo "$end - $start" | bc)
    echo "Risc0,$n,$(format_time $time)" >> $OUTPUT_FILE
done
