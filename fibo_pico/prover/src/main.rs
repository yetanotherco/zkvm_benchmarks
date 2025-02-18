use std::fs;

extern crate pico_sdk;


use pico_sdk::{client::DefaultProverClient, init_logger};
/// Loads an ELF file from the specified path.

pub fn load_elf(path: &str) -> Vec<u8> {
    fs::read(path).unwrap_or_else(|err| {
        panic!("Failed to load ELF file from {}: {}", path, err);
    })
}


fn main() {
    // Initialize logger
    init_logger();

    let args: Vec<String> = std::env::args().collect();
    let n = args.get(1)
        .and_then(|s| s.parse::<u32>().ok())
        .expect("Missing the number of times to do fibonacci as an argument");

    // Load the ELF file
    let elf = load_elf("../elf/riscv32im-pico-zkvm-elf");

    // Initialize the prover client
    let client = DefaultProverClient::new(&elf);
    let stdin_builder = client.get_stdin_builder();

    // Set up input
    stdin_builder.borrow_mut().write(&n);

    // Generate proof
    let _proof = client.prove("asd.proof".into()).expect("Failed to generate proof");

    // Decodes public values from the proof's public value stream.
    // let public_buffer = proof.pv_stream.unwrap();

    // Deserialize public_buffer into FibonacciData
    // let _public_values: FibonacciData =
    //    bincode::deserialize(&public_buffer).expect("Failed to deserialize");
}
