use hello_world::ed25519::Point;

/// ring signature structure
#[derive(Drop)]
pub struct RingSignature {
    pub message: u256, // clear message
    pub c: u256,
    pub responses: Array<u256>,
    pub ring: Array<Point>,
    // pub curve: Curve,
}

///Enum for the curve, will be use to do pattern matching on the curve
#[derive(Drop)]
pub enum Curve {
    Secp256k1,
    Ed15519
}


enum VerificationParams {
    index: u256,
    previousR: Option<u256>,
    previousC: Option<u256>,
    previousIndex: Option<u256>,
    alpha: Option<u256>
}

