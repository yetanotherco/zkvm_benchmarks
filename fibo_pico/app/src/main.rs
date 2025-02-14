#![no_main]

pico_sdk::entrypoint!(main);
use fibonacci_lib::FibonacciData;
use pico_sdk::io::{commit, read_as};

pub fn main() {
    // Read inputs `n` from the environment
    let n: u32 = read_as();

    println!("Fibo of: {}", n);

    let mut a = 0;
    let mut b = 1;
    for _ in 0..n {
        let mut c = a + b;
        c %= 7919; // Modulus to prevent overflow.
        a = b;
        b = c;
    }
                                               //
    // Commit the assembled Fibonacci data as the public values in the Pico proof.
    // This allows the values to be verified by others.
    let result = FibonacciData {
        n,
        a: a,
        b: b,
    };

    commit(&result);
}
