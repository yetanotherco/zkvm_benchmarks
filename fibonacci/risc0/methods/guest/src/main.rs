use risc0_zkvm::guest::env;

fn main() {

    let n: u32 = env::read();

    // Write n to public input
    env::commit(&n);

    // Compute the n'th fibonacci number, using normal Rust code.
    let mut a = 0;
    let mut b = 1;
    for _ in 0..n {
        let mut c = a + b;
        c %= 7919; // Modulus to prevent overflow.
        a = b;
        b = c;
    }

    env::commit(&a);
    env::commit(&b);
}
