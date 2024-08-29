use core::keccak::keccak_u256s_be_inputs;
use core::keccak::keccak_u256s_le_inputs;
use core::keccak::compute_keccak_byte_array;
use alexandria_encoding::reversible::ReversibleBytes;
//#[test]
//#[available_gas(3200000000)]
fn test_ts() {
    //TODO find a keccak that returns the same value on ts and cairo
    let a: u256 = 20;
    //    println!("{:?} ", a.high);
    //    println!("{:?} ", a.low);

    let Gle: u256 = keccak_u256s_le_inputs((array![a]).span());
    let gler = Gle.reverse_bytes();
    let Gbe: u256 = keccak_u256s_be_inputs(array![a].span());
    let gber = Gbe.reverse_bytes();
    //   println!("little endian hash {:?}", Gle);
//   println!("le hash be {:?}", gler);
//   println!("big endian hash le {:?}", Gbe);
//   println!("big endian hash be {:?}", gber);
}
