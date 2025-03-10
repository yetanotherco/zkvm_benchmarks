// This code was borrowed from https://github.com/succinctlabs/zkvm-perf/blob/main/programs/rsp-risc0/src/main.rs

#![no_main]

use rsp_client_executor::{executor::EthClientExecutor, io::EthClientExecutorInput};
use std::sync::Arc;

risc0_zkvm::guest::entry!(main);

pub fn main() {
    // Read the input.
    let input: Vec<u8> = risc0_zkvm::guest::env::read();
    let input = bincode::deserialize::<EthClientExecutorInput>(&input).unwrap();

    // Execute the block.
    let executor = EthClientExecutor::eth(
        Arc::new((&input.genesis).try_into().unwrap()),
        input.custom_beneficiary,
    );
    let header = executor.execute(input).expect("failed to execute client");
    let block_hash = header.hash_slow();
    println!("block_hash: {:?}", block_hash);
}