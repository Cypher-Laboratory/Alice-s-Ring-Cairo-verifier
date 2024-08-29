use alexandria_encoding::reversible::ReversibleBytes;
use alexandria_ascii::integer::ToAsciiTrait;
pub mod ed25519;
pub mod keccak;
pub mod structType;
use ed25519::{l, Point, point_mult, getG, ExtendedHomogeneousPoint};
use core::keccak::keccak_u256s_be_inputs;
use structType::RingSignature;

//TODO this function for Secp256k1
//NOTE this function is a rewrite in cairo of the following typescript function, it aims to have the
//input/output
//TDOO find a way to have an equivalent hash between cairo and typescript
fn computeCEd25519(
    ring: Span<Point>, message: u256, mut serializedRing: Array<u256>, params: VerificationParams
) -> u256 {
    let G = getG();
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


//TODO implement the function
//fn serializeEd25519Ring(ring : Span<Point>)->Span<ByteArray>{}

///Enum for the curve, will be use to do pattern matching on the curve
#[derive(Drop)]
enum Curve {
    Secp256k1,
    Ed15519
}
#[derive(Drop, Destruct)]
struct VerificationParams {
    index: u32,
    previousR: u256,
    previousC: u256,
    previousIndex: u32
}

pub fn verify(signature: RingSignature) -> bool {
    let mut lastComputedC = signature.c;
    let ring_len = signature.ring.len();
    let mut i: u32 = 0;
    let messageDigest = keccak_u256s_be_inputs(array![signature.message].span()).reverse_bytes();
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
                }
            );
        i += 1;
    };
    println!("last computed c {:?} ", lastComputedC);
    signature.c == lastComputedC
}
