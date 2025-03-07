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

OUTPUT_FILE="benchmark_reth_gpu_results.csv"

# Build all projects
echo "Building all projects..."
make build_rsp_sp1 SP1_PROVER="cuda"
make build_rsp_risc0_cuda

# Initialize results file
echo "Prover,Megagas,Time" > $OUTPUT_FILE

for n in "${N_VALUES[@]}"; do
    # Run rsp_sp1 benchmark
    echo "Running RSP SP1 with BLOCK_MEGAGAS=$n"
    start=$(date +%s.%N)
    SP1_PROVER="cuda" make rsp_sp1 BLOCK_MEGAGAS=$n > /dev/null 2>&1
    end=$(date +%s.%N)
    time=$(echo "$end - $start" | bc)
    echo "RSP SP1,$n,$(format_time $time)" >> $OUTPUT_FILE

    # Run rsp_risc0 benchmark
    echo "Running RSP RISC0 with BLOCK_MEGAGAS=$n"
    start=$(date +%s.%N)
    make rsp_risc0_cuda BLOCK_MEGAGAS=$n > /dev/null 2>&1
    end=$(date +%s.%N)
    time=$(echo "$end - $start" | bc)
    echo "RSP RISC0,$n,$(format_time $time)" >> $OUTPUT_FILE
done
