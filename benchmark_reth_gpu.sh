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
    N_VALUES=(1 6 15 24 36) # ~ 10KB 100KB 1MB
fi

OUTPUT_FILE="benchmark_reth_gpu_results.csv"

# Build all projects
echo "Building all projects..."
make build_rsp_sp1 RUSTFLAGS="cuda"
make build_rsp_pico

# Initialize results file
echo "Prover,N,Time" > $OUTPUT_FILE

for n in "${N_VALUES[@]}"; do
    # Run rsp_sp1 benchmark
    echo "Running RSP SP1 with BLOCK_MEGAGAS=$n"
    start=$(date +%s.%N)
    make rsp_sp1 BLOCK_MEGAGAS=$n > /dev/null 2>&1
    end=$(date +%s.%N)
    time=$(echo "$end - $start" | bc)
    echo "RSP SP1,$n,$(format_time $time)" >> $OUTPUT_FILE
done
