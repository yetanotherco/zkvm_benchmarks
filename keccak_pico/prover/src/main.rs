use std::{fs, path::PathBuf};
use alloy_sol_types::private::primitives::hex;

extern crate pico_sdk;
extern crate rand;
extern crate tiny_keccak;
extern crate alloy_sol_types;

use rand::rngs::StdRng; // Import StdRng
use rand::SeedableRng;
use rand::RngCore;

use pico_sdk::{client::DefaultProverClient, init_logger};
use tiny_keccak::{Hasher, Keccak};

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
        .and_then(|s| s.parse::<usize>().ok())
        .expect("Missing the number of times to do fibonacci as an argument");

    // Load the ELF file
    let elf = load_elf("keccak_pico/elf/riscv32im-pico-zkvm-elf");

    // Initialize the prover client
    let client = DefaultProverClient::new(&elf);
    let stdin_builder = client.get_stdin_builder();

    let mut data = vec![0u8; n];
    // Seed the RNG for reproducibility.
    let seed: [u8; 32] = [42; 32]; // Fixed seed for reproducibility
    let mut rng = StdRng::from_seed(seed);
    rng.fill_bytes(&mut data); // Fill the data vector with random bytes

    // Set up input
    stdin_builder.borrow_mut().write_slice(&data);

    let pv_path = PathBuf::from("./");

    // Generate proof
    let _proof = client.prove(pv_path).expect("Failed to generate proof");

    let string = fs::read_to_string("./pv_file").expect("Failed to read public_values");
    let hash_result = hex::decode(&string).expect("Failed to decode public_values");
    println!("Obtained output: {:?}", hash_result);
    let expected_keccak = keccak(&data);
    println!("Expected output: {:?}", expected_keccak);
    assert_eq!(hash_result, expected_keccak);

    // Deserialize public_buffer into FibonacciData
    // let _public_values: FibonacciData =
    //    bincode::deserialize(&public_buffer).expect("Failed to deserialize");
}

fn keccak(bytes: &[u8]) -> [u8; 32] {
    // Compute the keccak of length N, using normal Rust code.
    let mut hash = [0u8; 32];
    let mut keccak256 = Keccak::v256();
    keccak256.update(&bytes);
    keccak256.finalize(&mut hash);
    hash
}
