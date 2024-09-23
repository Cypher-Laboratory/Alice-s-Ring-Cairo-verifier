use core::circuit::u384;
use garaga::ec_ops::{G1Point, MSMHint, DerivePointFromXHint};
use garaga::definitions::{u384Serde};

/// ring signature structure adapted to use the garaga msm hint
// Could may be be optimized by removing the ring and only use the point in the hint
#[derive(Drop,Serde)]
pub struct RingSignature {
    pub message: u384, // clear message
    pub c: u384,
    pub ring: Span<G1Point>,
    pub hints: Span<GaragaMSMParam>
}

///Enum for the curve, will be use to do pattern matching based on the curve
#[derive(Drop)]
pub enum Curve {
    Secp256k1,
    Ed15519
}

#[derive(Drop, Destruct,Serde)]
pub struct VerificationParams {
    pub index: u32,
    pub previousR: u256,
    pub previousC: u256,
    pub previousIndex: u32
}

#[derive(Drop, Destruct, Serde)]
pub struct GaragaMSMParam {
    pub scalars_digits_decompositions: Option<Span<(Span<felt252>, Span<felt252>)>>,
    pub hint: MSMHint,
    pub derive_point_from_x_hint: DerivePointFromXHint,
    pub points: Span<G1Point>,
    pub scalars: Span<u256>,
    pub curve_index: usize
}
