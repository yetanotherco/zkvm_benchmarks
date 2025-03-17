// This code was borrowed from https://github.com/succinctlabs/zkvm-perf/blob/main/programs/rsp-risc0/src/main.rs

#![no_main]

use risc0_zkvm::{guest::env, sha::Digest};
use rsp_client_executor::{io::ClientExecutorInput, ClientExecutor, EthereumVariant};
use tiny_keccak::{Hasher, Keccak};
risc0_zkvm::guest::entry!(main);

pub fn main() {
    // Read the input.
    let input: Vec<u8> = env::read_frame();
    println!("{:?}", &input[..16]);

    let mut hash = [0u8; 32];
    let mut keccak256 = Keccak::v256();
    keccak256.update(&input);
    keccak256.finalize(&mut hash);
    let digest = Digest::from_bytes(hash);
    println!("{:?}", digest);

    let input = bincode::deserialize::<ClientExecutorInput>(&input).unwrap();

    // Execute the block.
    let executor = ClientExecutor;
    let header = executor.execute::<EthereumVariant>(input).expect("failed to execute client");
    let block_hash = header.hash_slow();

    env::commit(&block_hash);
}
