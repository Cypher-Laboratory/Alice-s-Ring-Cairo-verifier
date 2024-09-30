pub mod structType;

use core::circuit::u384;
use core::poseidon::poseidon_hash_span;
use garaga::ec_ops::{msm_g1, G1Point};
use garaga::definitions::{u384Serde, get_n};
use structType::{RingSignature, GaragaMSMParam};

//function to compute challenge using garaga
// CAUTION if curve == ED25519 the points are represented in their weirstrass form
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
    u384Serde::serialize(@point.x, ref serializedRing);
    u384Serde::serialize(@point.y, ref serializedRing);
    (poseidon_hash_span(serializedRing.span()).into() % l).into()
}

fn serializeRing(ring: Span<G1Point>, message: u384) -> Array<felt252> {
    let mut r: Array<felt252> = ArrayTrait::new();
    for p in ring {
        u384Serde::serialize(p.y, ref r);
    };
    u384Serde::serialize(@message, ref r);
    r
}

pub fn verify(signature: RingSignature) -> bool {
    let mut last_computed_c = signature.c;
    let hints_len = signature.hints.len();
    let serialized_ring = serializeRing(signature.ring, signature.message_digest);
    let mut has_broken = false;
    let mut i: u32 = 0;
    let l = get_n(*signature.hints.at(0).curve_index);
    loop {
        if i >= hints_len - 1 {
            break;
        }
        last_computed_c = computeCEd25519Garaga(signature.hints.at(i), serialized_ring.clone(), l);

        let next_hint_ref = signature.hints.at(i + 1);
        if last_computed_c != (*next_hint_ref.scalars[1]).into() {
            has_broken = true;
            break;
        }
        i += 1;
    };
    if has_broken {
        return false;
    }
    last_computed_c = computeCEd25519Garaga(signature.hints.at(hints_len - 1), serialized_ring, l);
    signature.c == last_computed_c
}
