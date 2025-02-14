#!/bin/bash

# Array of N values to test
N_VALUES=(10 100)
OUTPUT_FILE="benchmark_results.csv"

# Create CSV header
echo "Prover,N,Time(s)" > $OUTPUT_FILE

for n in "${N_VALUES[@]}"; do
    # Pico
    echo "Running Pico with N=$n"
    start=$(date +%s.%N)
    make fibo_pico_wrapped N=$n > /dev/null 2>&1
    end=$(date +%s.%N)
    time=$(echo "$end - $start" | bc)
    echo "Pico,$n,$time" >> $OUTPUT_FILE

    # SP1
    echo "Running SP1 with N=$n"
    start=$(date +%s.%N)
    make fibo_sp1 N=$n PROOF_MODE=compressed > /dev/null 2>&1
    end=$(date +%s.%N)
    time=$(echo "$end - $start" | bc)
    echo "SP1,$n,$time" >> $OUTPUT_FILE

    # RISC0
    echo "Running RISC0 with N=$n"
    start=$(date +%s.%N)
    make fibo_risc0 N=$n > /dev/null 2>&1
    end=$(date +%s.%N)
    time=$(echo "$end - $start" | bc)
    echo "RISC0,$n,$time" >> $OUTPUT_FILE
done
