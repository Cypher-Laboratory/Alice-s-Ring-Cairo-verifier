use alices_ring_cairo_verifier::ed25519::Point;

/// ring signature structure
#[derive(Drop)]
pub struct RingSignature {
    pub message: u256, // clear message
    pub c: u256,
    pub responses: Array<u256>,
    pub ring: Array<Point>,
    // pub curve: Curve,
}

///Enum for the curve, will be use to do pattern matching based on the curve
#[derive(Drop)]
pub enum Curve {
    Secp256k1,
    Ed15519
}

#[derive(Drop, Destruct)]
pub struct VerificationParams {
    pub index: u32,
    pub previousR: u256,
    pub previousC: u256,
    pub previousIndex: u32
}
