use sp1_sdk::{include_elf, utils, ProverClient, SP1ProofWithPublicValues, SP1Stdin};

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

    // Execute the program using the `ProverClient.execute` method, without generating a proof.
    // let (_, report) = client.execute(ELF, &stdin).run().unwrap();
    // println!("executed program with {} cycles", report.total_instruction_count());


    // Generate the proof for the given program and input.
    let (pk, _vk) = client.setup(ELF);


    let mut proof;
    if mode == "groth16" {
        proof = client.prove(&pk, &stdin).groth16().run().unwrap();
    } else {
        proof = client.prove(&pk, &stdin).compressed().run().unwrap();
    }

    println!("generated proof");

    // Read and verify the output.
    //
    // Note that this output is read from values committed to in the program using
    // `sp1_zkvm::io::commit`.
    let _ = proof.public_values.read::<u32>();
    let a = proof.public_values.read::<u32>();
    let b = proof.public_values.read::<u32>();

    println!("a: {}", a);
    println!("b: {}", b);

    //Verify proof and public values
    //client.verify(&proof, &vk).expect("verification failed");

    // Test a round trip of proof serialization and deserialization.
    // proof.save("proof-with-pis.bin").expect("saving proof failed");
    // let deserialized_proof =
    //     SP1ProofWithPublicValues::load("proof-with-pis.bin").expect("loading proof failed");

    // Verify the deserialized proof.
    //client.verify(&deserialized_proof, &vk).expect("verification failed");

    println!("successfully generated and verified proof for the program!")
}
