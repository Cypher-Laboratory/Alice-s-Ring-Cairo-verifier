use hello_world::keccak::keccak_u256s_be_inputs;
use hello_world::keccak::keccak_u256s_le_inputs;
use hello_world::keccak::cairo_keccak;
use hello_world::keccak::compute_keccak_byte_array;
use alexandria_encoding::reversible::ReversibleBytes;

#[test]
#[available_gas(3200000000)]
fn test_ts() {
    //TODO find a keccak that returns the same value on ts and cairo
    let Gbe: u256 = keccak_u256s_be_inputs(array![1, 2, 3, 4, 5].span());
    let hle: u256 = keccak_u256s_le_inputs(array![1, 2, 3, 4].span());

    let hashed_byte_array = compute_keccak_byte_array(@"this is a test");
    let mut a: Array<u64> = array![
        0,
        0,
        0,
        72057594037927936,
        0,
        0,
        0,
        144115188075855872,
        0,
        0,
        0,
        216172782113783808,
        0,
        0,
        0,
        288230376151711744
    ];
    let test_cairo_keccak = cairo_keccak(ref a, 0, 0);
    //    println!("test cairo_keccak {:?}", test_cairo_keccak);
//    println!("---------------------------------------------");
//   println!("big endian hash le here {:?}", Gbe);
//  println!("big endian hash be here {:?}", Gbe.reverse_bytes());
// println!("---------------------------------------------");
//  println!("little endian hash le {:?}", hle);
//  println!("little endian hash be {:?}", hle.reverse_bytes());
// println!("byte array hash le here {:?}", hashed_byte_array);

    //THIS IS HOW WE ARE GOING TO HASH THE STUFF
//println!(
//    "here there is a match byte array hash be here {:?}", hashed_byte_array.reverse_bytes()
// );
}
