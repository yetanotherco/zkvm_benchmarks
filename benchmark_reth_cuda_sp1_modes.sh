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
    N_VALUES=(1)
else
    N_VALUES=(1 3 9 18 27 36)
fi

OUTPUT_FILE="benchmark_reth_gpu_results_sp1_modes.csv"

# Build all projects
echo "Building all projects..."
make build_rsp_sp1 SP1_PROVER="cuda"

# Initialize results file
echo "Prover,N,Time,Size" > $OUTPUT_FILE

for n in "${N_VALUES[@]}"; do
    # Run rsp_sp1 benchmark (Compressed)
    echo "Running RSP SP1 Compressed with BLOCK_MEGAGAS=$n"
    start=$(date +%s.%N)
    SP1_PROVER="cuda" make rsp_sp1 BLOCK_MEGAGAS=$n PROOF_MODE=compressed SAVE_PROOF=true > /dev/null 2>&1
    end=$(date +%s.%N)
    time=$(echo "$end - $start" | bc)
    proof_file="proofs/rsp_proof-with-pis-compressed-${n}M.bin"
    proof_size=$(stat --format="%s" "$proof_file" 2>/dev/null || echo "N/A")
    echo "RSP SP1-Compressed,$n,$(format_time $time),$proof_size" >> $OUTPUT_FILE

    # Run rsp_sp1 benchmark (Groth16)
    echo "Running RSP SP1 Groth16 with BLOCK_MEGAGAS=$n"
    start=$(date +%s.%N)
    SP1_PROVER="cuda" make rsp_sp1 BLOCK_MEGAGAS=$n PROOF_MODE=groth16 SAVE_PROOF=true > /dev/null 2>&1
    end=$(date +%s.%N)
    time=$(echo "$end - $start" | bc)
    proof_file="proofs/rsp_proof-with-pis-groth16-${n}M.bin"
    proof_size=$(stat --format="%s" "$proof_file" 2>/dev/null || echo "N/A")
    echo "RSP SP1-Groth16,$n,$(format_time $time),$proof_size" >> $OUTPUT_FILE

    # Run rsp_sp1 benchmark (Core)
    echo "Running RSP SP1 Core with BLOCK_MEGAGAS=$n"
    start=$(date +%s.%N)
    SP1_PROVER="cuda" make rsp_sp1 BLOCK_MEGAGAS=$n PROOF_MODE=core SAVE_PROOF=true > /dev/null 2>&1
    end=$(date +%s.%N)
    time=$(echo "$end - $start" | bc)
    proof_file="proofs/rsp_proof-with-pis-core-${n}M.bin"
    proof_size=$(stat --format="%s" "$proof_file" 2>/dev/null || echo "N/A")
    echo "RSP SP1-Core,$n,$(format_time $time),$proof_size" >> $OUTPUT_FILE
done
