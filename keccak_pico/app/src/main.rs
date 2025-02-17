#![no_main]

pico_sdk::entrypoint!(main);
use tiny_keccak::{Hasher, Keccak};
use pico_sdk::io::{commit, read_as};

pub fn main() {
    // Read inputs `n` from the environment
    let bytes = read_vec();

    let mut hash = [0u8; 32];
    let mut keccak256 = Keccak::v256();
    keccak256.update(&bytes);
    keccak256.finalize(&mut hash);

    commit(&hash);
}
