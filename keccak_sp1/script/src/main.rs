use sp1_sdk::{include_elf, utils, ProverClient, SP1Stdin};
use tiny_keccak::{Keccak, Hasher}; // Import Keccak and Hasher from tiny_keccak
use rand::RngCore;
use rand::rngs::StdRng; // Import StdRng
use rand::SeedableRng; // Import SeedableRng trait

/// The ELF we want to execute inside the zkVM.
const ELF: &[u8] = include_elf!("keccak-program");

fn main() {
    // Setup a tracer for logging.
    utils::setup_logger();

    let args: Vec<String> = std::env::args().collect();
    let n = args.get(1)
        .and_then(|s| s.parse::<usize>().ok())
        .expect("Should pass the number of bytes to hash");

    let args: Vec<String> = std::env::args().collect();
    let mode = args.get(2)
        .map(|s| s.to_lowercase())
        .unwrap_or_else(|| "compressed".to_string());

    // Generate proof.
    let mut stdin = SP1Stdin::new();

    let mut data = vec![0u8; n];
    // Seed the RNG for reproducibility.
    let seed: [u8; 32] = [42; 32]; // Fixed seed for reproducibility
    let mut rng = StdRng::from_seed(seed);
    rng.fill_bytes(&mut data); // Fill the data vector with random bytes

    stdin.write_vec(data.clone()); // Write the data to stdin

    let start = std::time::Instant::now();
    let client = ProverClient::from_env();

    let (pk, _vk) = client.setup(ELF);
    println!("Setup in {:?}", start.elapsed());

    // let (_, report) = client.execute(ELF, &stdin).run().unwrap();
    // println!("executed program with {} cycles", report.total_instruction_count());

    let mut proof;
    if mode == "groth16" {
        proof = client.prove(&pk, &stdin).groth16().run().unwrap();
    } else {
        proof = client.prove(&pk, &stdin).compressed().run().unwrap();
    }
    // Save the proof.
    // proof.save("proof-with-io.json").expect("saving proof failed");

    println!("Successfully generated proof");

    let mut hash_result: [u8; 32] = [42; 32]; // Fixed seed for reproducibility
    proof.public_values.read_slice(&mut hash_result);
    println!("Obtained output: {:?}", hash_result);
    let expected_keccak = keccak(&data);
    println!("Expected output: {:?}", expected_keccak);
    assert_eq!(hash_result, expected_keccak);
}

fn keccak(bytes: &[u8]) -> [u8; 32] {
    // Compute the keccak of length N, using normal Rust code.
    let mut hash = [0u8; 32];
    let mut keccak256 = Keccak::v256();
    keccak256.update(&bytes);
    keccak256.finalize(&mut hash);
    hash
}
