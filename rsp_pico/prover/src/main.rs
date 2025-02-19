use std::{fs, path::PathBuf};

extern crate pico_sdk;
extern crate rand;
extern crate rsp_client_executor;
use rsp_client_executor::{io::ClientExecutorInput, CHAIN_ID_ETH_MAINNET};


use pico_sdk::{client::DefaultProverClient, init_logger};
/// Loads an ELF file from the specified path.

pub fn load_elf(path: &str) -> Vec<u8> {
    fs::read(path).unwrap_or_else(|err| {
        panic!("Failed to load ELF file from {}: {}", path, err);
    })
}

fn load_input_from_cache(chain_id: u64, block_number: u64) -> ClientExecutorInput {
    let cache_path = PathBuf::from(format!("./input/{}/{}.bin", chain_id, block_number));
    let mut cache_file = std::fs::File::open(cache_path).unwrap();
    let client_input: ClientExecutorInput = bincode::deserialize_from(&mut cache_file).unwrap();

    client_input
}


fn main() {
    // Initialize the logger.
    init_logger();

    // Load the input from the cache.
    let client_input = load_input_from_cache(CHAIN_ID_ETH_MAINNET, 20526624);

    // Load the ELF file
    let elf = load_elf("rsp_pico/elf/riscv32im-pico-zkvm-elf");

    // Initialize the prover client
    let client = DefaultProverClient::new(&elf);

    // Write the block to the program's stdin.
    let stdin_builder = client.get_stdin_builder();
    stdin_builder.borrow_mut().write(&client_input);


    let pv_path = PathBuf::from("./");

    // Generate proof
    let _proof = client.prove(pv_path).expect("Failed to generate proof");

    // Decodes public values from the proof's public value stream.
    // let public_buffer = proof.pv_stream.unwrap();

    // Deserialize public_buffer into FibonacciData
    // let _public_values: FibonacciData =
    //    bincode::deserialize(&public_buffer).expect("Failed to deserialize");
}
