# zkVMs benchmarks

## Preeliminary results

I'll help you convert these tables into clean markdown format. I'll organize them by the different sections in the data.

# Hardware Benchmarks (n=10000)

## M3 GPU Results (40 GiB or more)

| System | Time Avg [s] | Time Min [s] | Time Max [s] | Proof size | Individual Time Measurements [s] |
|--------|-------------|--------------|--------------|------------|--------------------------------|
| SP1 (Compressed) | 51 | 49 | 55 | 1.3M | 49, 51, 55, 48.6, 49 |
| SP1 (Groth16 compressed) | Fails | Fails | Fails | - | - |
| Pico (Gnark compressed) | Fails | Fails | Fails | - | - |

## Intel Xeon Gold 6226R (16 cores) Results (n=10000)

| Implementation | Time Avg [h:m:s] | Time Min [h:m:s] | Time Max [h:m:s] | Proof size | Individual Time Measurements |
|----------------|------------------|------------------|------------------|------------|----------------------------|
| SP1 (Compressed, no avx) | 0:01:46 | 0:01:46 | 0:01:46 | 1.3M | 0:01:46 |
| SP1 (Groth16 compressed, no avx) | 0:05:06 | 0:04:58 | 0:05:16 | 1.4K | 0:05:04, 0:05:16, 0:04:58 |
| SP1 (Compressed, avx) | 0:01:17 | 0:01:16 | 0:01:17 | 1.3M | 0:01:16, 0:01:17, 0:01:17 |
| SP1 (Gnark compressed, avx) | 0:04:19 | 0:04:18 | 0:04:20 | 1.4K | 0:04:20, 0:04:18, 0:04:19 |
| Pico (Gnark compressed) | 6:00:49 | 0:01:02 | 0:00:00 | 893K | 0:01:02, 0:01:06, 0:01:08 |

## Results for n=4M

| Implementation | Time Avg [h:m:s] | Time Min [h:m:s] | Time Max [h:m:s] | Proof size |
|----------------|------------------|------------------|------------------|------------|
| SP1 (Compressed, no avx) | - | - | - | - |
| SP1 (Groth16 compressed, no avx) | 0:40:21 | 0:40:21 | 0:40:21 | - |
| SP1 (Compressed, avx) | - | - | - | - |
| SP1 (Gnark compressed, avx) | 0:28:37 | 0:28:37 | 0:28:37 | - |
| Pico (Gnark compressed) | 0:43:16 | 0:43:16 | 0:43:16 | - |


Would you like me to modify the formatting in any way?

## Commands

Set N for fibo examples

```PROOF_MODE=compressed make fibo_sp1_10k```

```PROOF_MODE=groth16 make fibo_sp1_10k```

```N=5 make fibo_risc0```


## 
