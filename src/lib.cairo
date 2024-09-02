pub mod ed25519;
pub mod structType;
use alexandria_encoding::reversible::ReversibleBytes;
use core::keccak::keccak_u256s_be_inputs;
use ed25519::{l, Point, point_mult, getG, ExtendedHomogeneousPoint};
use structType::{RingSignature, VerificationParams};

//TODO this function for secp256k1/secp256r1 and stark curve.
//TODO try using pedersen hash to reduce gas cost
fn computeCEd25519(
    ring: Span<Point>,
    message: u256,
    mut serializedRing: Array<u256>,
    params: VerificationParams,
    G: Point
) -> u256 {
    let _GpreviousR: ExtendedHomogeneousPoint = point_mult(params.previousR, G.into());
    let ringPreviousIndex = *ring[params.previousIndex];
    let _CRingPreviousIndex: ExtendedHomogeneousPoint = point_mult(
        params.previousC, ringPreviousIndex.into()
    );
    let _point: Point = (_GpreviousR + _CRingPreviousIndex).into();
    serializedRing.append(message);
    serializedRing.append(_point.y);
    let hash = keccak_u256s_be_inputs(serializedRing.span()).reverse_bytes();
    return hash % l;
}


fn serializeRing(ring: Span<Point>) -> Array<u256> {
    let mut r: Array<u256> = ArrayTrait::new();
    for p in ring {
        r.append(*p.y);
    };
    r
}


//can be optimized by giving the hash of the message and not hash it on chain
pub fn verify(signature: RingSignature) -> bool {
    let mut lastComputedC = signature.c;
    let ring_len = signature.ring.len();
    //let ring_span = signature.ring.span();
    let mut i: u32 = 0;
    let G = getG();
    let messageDigest = keccak_u256s_be_inputs(array![signature.message].span()).reverse_bytes();
    //let serializedRing =
    loop {
        if i >= ring_len {
            break;
        }
        lastComputedC =
            computeCEd25519(
                signature.ring.span(),
                messageDigest,
                serializeRing(signature.ring.span()),
                VerificationParams {
                    index: (i + 1) % ring_len,
                    previousR: *signature.responses.at(i),
                    previousC: lastComputedC,
                    previousIndex: i,
                },
                G
            );
        i += 1;
    };
    signature.c == lastComputedC
}

