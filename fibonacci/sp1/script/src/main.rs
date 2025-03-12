use sp1_sdk::{include_elf, utils, ProverClient, SP1Stdin};

/// The ELF we want to execute inside the zkVM.
const ELF: &[u8] = include_elf!("fibonacci-program");

fn main() {
    // Setup logging.
    utils::setup_logger();

    let args: Vec<String> = std::env::args().collect();
    let n = args.get(1)
        .and_then(|s| s.parse::<u32>().ok())
        .unwrap_or(0);

    let mode = args.get(2)
        .map(|s| s.to_lowercase())
        .unwrap_or_else(|| "compressed".to_string());

    println!("SP1, fibo: {}, mode: {}", n, mode);

    // The input stream that the program will read from using `sp1_zkvm::io::read`. Note that the
    // types of the elements in the input stream must match the types being read in the program.
    let mut stdin = SP1Stdin::new();
    stdin.write(&n);

    // Create a `ProverClient` method.
    let client = ProverClient::from_env();

    // Generate the proof for the given program and input.
    let (pk, _vk) = client.setup(ELF);

    let mut _proof;
    if mode == "groth16" {
        _proof = client.prove(&pk, &stdin).groth16().run().unwrap();
    } else {
        _proof = client.prove(&pk, &stdin).compressed().run().unwrap();
    }

    println!("generated proof");
}
