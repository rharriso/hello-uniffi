use std::env;

fn main() {
    println!("CARGO_MANIFEST_DIR: {}", env::var("CARGO_MANIFEST_DIR").unwrap());

    let udl_path = format!(
        "{}/src/weightlifting_core.udl",
        env::var("CARGO_MANIFEST_DIR").unwrap()
    );
    uniffi::generate_scaffolding(&udl_path).unwrap();
}