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

# Array of N values to test
N_VALUES=(10)
OUTPUT_FILE="benchmark_results.csv"

# First build all projects
echo "Building all projects..."
make build_pico build_sp1 build_risc0

# Create CSV header
echo "Prover,Fibonacci N,Time" > $OUTPUT_FILE

for n in "${N_VALUES[@]}"; do
    # Pico
    echo "Running Pico with N=$n"
    start=$(date +%s.%N)
    make fibo_pico_wrapped N=$n > /dev/null 2>&1
    end=$(date +%s.%N)
    time=$(echo "$end - $start" | bc)
    formatted_time=$(format_time $time)
    echo "Pico Groth16,$n,$formatted_time" >> $OUTPUT_FILE

    # SP1 Compressed
    echo "Running SP1 (Compressed) with N=$n"
    start=$(date +%s.%N)
    
    # Set SP1 name based on acceleration
    if grep -q "avx512" /proc/cpuinfo; then
        sp1_name="SP1-AVX512"
    elif grep -q "avx2" /proc/cpuinfo; then
        sp1_name="SP1-AVX2"
    else
        sp1_name="SP1-Base"
    fi
    
    # Use environment variable if set, otherwise auto-detect
    if grep -q "avx512" /proc/cpuinfo; then
        make fibo_sp1 N=$n PROOF_MODE=compressed RUSTFLAGS="-C target-cpu=native -C target-feature=+avx512f" > /dev/null 2>&1
    elif grep -q "avx2" /proc/cpuinfo; then
        make fibo_sp1 N=$n PROOF_MODE=compressed RUSTFLAGS="-C target-cpu=native" > /dev/null 2>&1
    else
        make fibo_sp1 N=$n PROOF_MODE=compressed > /dev/null 2>&1
    fi
    
    end=$(date +%s.%N)
    time=$(echo "$end - $start" | bc)
    formatted_time=$(format_time $time)
    echo "$sp1_name,$n,$formatted_time" >> $OUTPUT_FILE

    # SP1 Groth16 (only on Linux with Docker)
    if [[ "$(uname)" == "Linux" ]] && command -v docker >/dev/null 2>&1; then
        echo "Running SP1 (Groth16) with N=$n"
        start=$(date +%s.%N)
        
        if grep -q "avx512" /proc/cpuinfo; then
            make fibo_sp1 N=$n PROOF_MODE=groth16 RUSTFLAGS="-C target-cpu=native -C target-feature=+avx512f" > /dev/null 2>&1
        elif grep -q "avx2" /proc/cpuinfo; then
            make fibo_sp1 N=$n PROOF_MODE=groth16 RUSTFLAGS="-C target-cpu=native" > /dev/null 2>&1
        else
            make fibo_sp1 N=$n PROOF_MODE=groth16 > /dev/null 2>&1
        fi
        
        end=$(date +%s.%N)
        time=$(echo "$end - $start" | bc)
        formatted_time=$(format_time $time)
        echo "$sp1_name-Groth16,$n,$formatted_time" >> $OUTPUT_FILE
    fi

    # RISC0
    echo "Running RISC0 with N=$n"
    start=$(date +%s.%N)
    make fibo_risc0 N=$n > /dev/null 2>&1
    end=$(date +%s.%N)
    time=$(echo "$end - $start" | bc)
    formatted_time=$(format_time $time)
    echo "Risc0,$n,$formatted_time" >> $OUTPUT_FILE
done
