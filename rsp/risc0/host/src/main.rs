// These constants represent the RISC-V ELF and the image ID generated by risc0-build.
// The ELF is used for proving and the ID is used for verification.
use std::{path::PathBuf, env};
// use alloy_primitives::B256;
use rsp_client_executor::{io::ClientExecutorInput};
use methods::{RSP_ELF, RSP_ID};
use risc0_zkvm::{default_prover, ExecutorEnv, ProverOpts, sha::Digest};
use tiny_keccak::{Hasher, Keccak};

fn load_input_from_cache(path: &str) -> ClientExecutorInput {
    //let cache_path = PathBuf::from(format!("./input/{}/{}.bin", chain_id, block_number));
    let cache_path = PathBuf::from(path);
    //println!("Cache path: {:?}", cache_path);
    let mut cache_file = std::fs::File::open(cache_path).unwrap();
    let client_input: ClientExecutorInput = bincode::deserialize_from(&mut cache_file).unwrap();

    client_input
}

fn main() {
    // Get the input path from command-line arguments
    let args: Vec<String> = env::args().collect();
    let input_path = if args.len() > 1 { &args[1] } else {
        panic!("Please provide the input path as an argument.");
    };

    let client_input = load_input_from_cache(input_path);
    let buffer = bincode::serialize(&client_input).unwrap();
    println!("{:?}", &buffer[..16]);

    let mut hash = [0u8; 32];
    let mut keccak256 = Keccak::v256();
    keccak256.update(&buffer);
    keccak256.finalize(&mut hash);
    let digest = Digest::from_bytes(hash);
    println!("{:?}", digest);


    // Initialize tracing
    tracing_subscriber::fmt()
        .with_env_filter(tracing_subscriber::filter::EnvFilter::from_default_env())
        .init();

    // Send the actual data, not just the length
    let env = ExecutorEnv::builder()
        .write_frame(&buffer)
        .build()
        .unwrap();

    // We are using the succinct prover options (compressed mode)
    let opts = ProverOpts::succinct();
    let prover = default_prover();

    // Proof information by proving the specified ELF binary.
    // This struct contains the receipt along with statistics about execution of the guest
    let prove_info = prover
        .prove_with_opts(env, RSP_ELF, &opts)
        .unwrap();

    // extract the receipt.
    let receipt = prove_info.receipt;

    // The receipt was verified at the end of proving, but the below code is an
    // example of how someone else could verify this receipt.
    receipt
        .verify(RSP_ID)
        .unwrap();
}
