use alices_ring_cairo_verifier::keccak_felt252_array;

#[test]
fn test_keccak() -> bool {
    let felts: Array<felt252> = array![1, 2];
    let hash = keccak_felt252_array(felts);
    println!("Hash: {:?}", hash);
    true
}
