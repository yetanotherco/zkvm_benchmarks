use risc0_zkvm::{guest::env, sha::Digest};
use tiny_keccak::{Hasher, Keccak};

fn main() {
    let bytes: Vec<u8> = env::read();

    // Compute the keccak of length N, using normal Rust code.
    let mut hash = [0u8; 32];
    let mut keccak256 = Keccak::v256();
    keccak256.update(&bytes);
    keccak256.finalize(&mut hash);
    let digest = Digest::from_bytes(hash);
    env::commit(&digest);
    // env::commit(&hash);
}
