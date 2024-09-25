pub mod structType;

use alexandria_encoding::reversible::ReversibleBytes;
use core::circuit::u384;
use core::keccak::keccak_u256s_be_inputs;
use garaga::ec_ops::{msm_g1, G1Point};
use garaga::definitions::{u384Serde, get_n};
use structType::{RingSignature, GaragaMSMParam};

//function to compute challenge using garaga
// CAUTION the points are represented in their weirstrass form
fn computeCEd25519Garaga(
    hints: @GaragaMSMParam, mut serializedRing: Array<felt252>, l: u256
) -> u384 {
    let point = msm_g1(
        *hints.scalars_digits_decompositions,
        *hints.hint,
        *hints.derive_point_from_x_hint,
        *hints.points,
        *hints.scalars,
        *hints.curve_index
    );
    u384Serde::serialize(@point.y, ref serializedRing);

    let challenge = (keccak_felt252_array(serializedRing) % l).into(); 
    challenge
}

fn serializeRing(ring: Span<G1Point>, message : u384) -> Array<felt252> {
    let mut r: Array<felt252> = ArrayTrait::new();
    for p in ring {
        u384Serde::serialize(p.y, ref r);
    };
    u384Serde::serialize(@message, ref r);
    r
}

// Compute the Keccak hash of a felt252 array
// CAUTION: the output is a u256 in big endian
pub fn keccak_felt252_array(arr: Array<felt252>) -> u256 {
    // Convert the felt252 array to a u256 array
    let mut u256_arr = ArrayTrait::new();
    let mut i = 0;
    loop {
        if i >= arr.len() {
            break;
        }
        let felt = *arr.at(i);
        let u256_value = felt.into();
        u256_arr.append(u256_value);
        i += 1;
    };
    // Compute the Keccak hash
    keccak_u256s_be_inputs(u256_arr.span()).reverse_bytes()
}

//can be optimized by giving the hash of the message and not hash it on chain
pub fn verify(signature: RingSignature) -> bool {
    let mut last_computed_c = signature.c;
    let hints_len = signature.hints.len();
    let serialized_ring = serializeRing(signature.ring, signature.message_digest);
    let mut has_broken = false;
    let mut i: u32 = 0;
    let l = get_n(*signature.hints.at(0).curve_index);
    loop {
        if i >= hints_len {
            break;
        }
        last_computed_c =
            computeCEd25519Garaga(
                signature.hints.at(i), serialized_ring.clone(), l
            );

        
        //let next_hint_ref = signature.hints.at(i + 1);
        //if last_computed_c != (*next_hint_ref.scalars[1]).into() {
        //    has_broken = true;
        //    break;
        //}
        i += 1;
    };
    signature.c == last_computed_c
}
