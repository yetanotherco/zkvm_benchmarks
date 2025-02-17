use fibonacci_lib::{FibonacciData, load_elf};
use pico_sdk::{client::DefaultProverClient, init_logger};

use rand::RngCore;
use rand::rngs::StdRng; // Import StdRng
use rand::SeedableRng; // Import SeedableRng trait
use std::env::args;

fn main() {
    // Initialize logger
    init_logger();

    // Load the ELF file
    let elf = load_elf("../elf/riscv32im-pico-zkvm-elf");

    // Initialize the prover client
    let client = DefaultProverClient::new(&elf);
    let stdin_builder = client.get_stdin_builder();

    // Set up input
    let n = 100u32;
    stdin_builder.borrow_mut().write(&n);

    // Generate proof
    let proof = client.prove_fast().expect("Failed to generate proof");

    // Decodes public values from the proof's public value stream.
    // let public_buffer = proof.pv_stream.unwrap();

    // Deserialize public_buffer into FibonacciData
    // let _public_values: FibonacciData =
    //    bincode::deserialize(&public_buffer).expect("Failed to deserialize");
}
