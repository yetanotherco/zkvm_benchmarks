use std::{path::PathBuf, env};
use alloy_primitives::B256;
use rsp_client_executor::{io::ClientExecutorInput};

use sp1_sdk::{include_elf, utils, ProverClient, SP1Stdin, SP1ProofWithPublicValues};
// const ELF: &[u8] = include_elf!("fibonacci-program");

fn load_input_from_cache(path: &str) -> ClientExecutorInput {
    //let cache_path = PathBuf::from(format!("./input/{}/{}.bin", chain_id, block_number));
    let cache_path = PathBuf::from(path);
    //println!("Cache path: {:?}", cache_path);
    let mut cache_file = std::fs::File::open(cache_path).unwrap();
    let client_input: ClientExecutorInput = bincode::deserialize_from(&mut cache_file).unwrap();

    client_input
}


fn main() {
    // Initialize the logger.
    utils::setup_logger();

    // Get the input path from command-line arguments
    let args: Vec<String> = env::args().collect();
    let input_path = if args.len() > 1 { &args[1] } else { 
        panic!("Please provide the input path as an argument."); 
    };
    let mode = args.get(2)
        .map(|s| s.to_lowercase())
        .unwrap_or_else(|| "compressed".to_string());
    let save_proof: bool = args.get(3)
        .map(|s| s.to_lowercase().parse::<bool>().unwrap_or(false))
        .unwrap_or(false);

    // Load the input from the cache.
    let client_input = load_input_from_cache(input_path);
    // Generate the proof.
    let client = ProverClient::from_env();

    // Setup the proving key and verification key.
    let (pk, vk) = client.setup(include_elf!("rsp-program"));

    // Write the block to the program's stdin.
    let mut stdin = SP1Stdin::new();
    let buffer = bincode::serialize(&client_input).unwrap();
    stdin.write_vec(buffer);

    // Only execute the program.
    let (mut public_values, execution_report) = client.execute(&pk.elf, &stdin).run().unwrap();
    println!(
        "Finished executing the block in {} cycles",
        execution_report.total_instruction_count()
    );

    // Read the block hash.
    let block_hash = public_values.read::<B256>();
    println!("success: block_hash={block_hash}");

    // If the `prove` argument was passed in, actually generate the proof.
    // It is strongly recommended you use the network prover given the size of these programs.
    println!("Starting proof generation.");
    // let proof = client.prove(&pk, &stdin).run().expect("Proving should work.");
    let proof;
    if mode == "groth16" {
        proof = client.prove(&pk, &stdin).groth16().run().unwrap();
    } else if mode == "compressed"{
        proof = client.prove(&pk, &stdin).compressed().run().unwrap();
    } else {
        proof = client.prove(&pk, &stdin).core().run().unwrap();
    }
    println!("Proof generation finished.");

    client.verify(&proof, &vk).expect("proof verification should succeed");

    if save_proof {
        // Test a round trip of proof serialization and deserialization.
        proof.save(&format!("proof-with-pis-{}.bin", mode)).expect("saving proof failed");
        let deserialized_proof =
            SP1ProofWithPublicValues::load("proof-with-pis.bin").expect("loading proof failed");

        // Verify the deserialized proof.
        client.verify(&deserialized_proof, &vk).expect("verification failed");
    }

    println!("successfully generated and verified proof for the program!")
}
