//CREDITS TO SHRAMEE : https://github.com/shramee/ed25519/blob/main/src/ed25519.cairo
use alexandria_math::mod_arithmetics::{
    add_mod, sub_mod, mult_mod, div_mod, pow_mod, add_inverse_mod, equality_mod
};
use alexandria_math::sha512::{sha512, SHA512_LEN};
use core::integer::u512;
use core::traits::TryInto;
use core::zeroable::NonZero;
use alexandria_data_structures::span_ext::SpanTraitExt;
// As per RFC-8032: https://datatracker.ietf.org/doc/html/rfc8032#section-5.1.7
// Variable namings in this function refer to naming in the RFC

pub const p: NonZero<u256> =
    57896044618658097711785492504343953926634992332820282019728792003956564819949; // 2^255 - 19
const d: u256 =
    37095705934669439343138083508754565189542113879843219016388785533085940283555; // d of Edwards255519, i.e. -121665/121666
pub const l: u256 =
    7237005577332262213973186563042994240857116359379907606001950938285454250989; // 2^252 + 27742317777372353535851937790883648493

const Gx: u256 =
    15112221349535400772501151409588531511454012693041857206046113283949847762202; // x od Edward25519
const Gy: u256 = 46316835694926478169428394003475163141307993866256225615783033603165251855960;

const TWO_POW_8: u256 = 0x100;
const TWO_POW_8_NON_ZERO: NonZero<u256> = 0x100;


#[derive(Drop, Copy, Serde, Debug)]
pub struct Point {
    pub x: u256,
    pub y: u256
}

#[derive(Drop, Copy)]
pub struct ExtendedHomogeneousPoint {
    X: u256,
    Y: u256,
    Z: u256,
    T: u256,
}

pub trait PointDoubling<T> {
    fn double(self: T) -> T;
}

impl PointDoublingExtendedHomogeneousPoint of PointDoubling<ExtendedHomogeneousPoint> {
    fn double(self: ExtendedHomogeneousPoint) -> ExtendedHomogeneousPoint {
        let A: u256 = mult_mod(self.X, self.X, p);
        let B: u256 = mult_mod(self.Y, self.Y, p);
        let C: u256 = mult_mod(2, mult_mod(self.Z, self.Z, p), p);
        let H: u256 = A + B;
        let E: u256 = sub_mod(H, pow_mod(add_mod(self.X, self.Y, p.into()), 2, p), p.into());
        let G: u256 = sub_mod(A, B, p.into());
        let F: u256 = add_mod(C, G, p.into());
        ExtendedHomogeneousPoint {
            X: mult_mod(E, F, p), Y: mult_mod(G, H, p), T: mult_mod(E, H, p), Z: mult_mod(F, G, p)
        }
    }
}

pub impl ExtendedHomogeneousPointAdd of Add<ExtendedHomogeneousPoint> {
    fn add(
        lhs: ExtendedHomogeneousPoint, rhs: ExtendedHomogeneousPoint
    ) -> ExtendedHomogeneousPoint {
        let A: u256 = mult_mod(sub_mod(lhs.Y, lhs.X, p.into()), sub_mod(rhs.Y, rhs.X, p.into()), p);
        let B: u256 = mult_mod(add_mod(lhs.Y, lhs.X, p.into()), add_mod(rhs.Y, rhs.X, p.into()), p);
        let C: u256 = mult_mod(mult_mod(mult_mod(lhs.T, 2, p), d, p), rhs.T, p);
        let D: u256 = mult_mod(mult_mod(lhs.Z, 2, p), rhs.Z, p);
        let E: u256 = sub_mod(B, A, p.into());
        let F: u256 = sub_mod(D, C, p.into());
        let G: u256 = add_mod(D, C, p.into());
        let H: u256 = add_mod(B, A, p.into());

        let X_3 = mult_mod(E, F, p);
        let Y_3 = mult_mod(G, H, p);
        let T_3 = mult_mod(E, H, p);
        let Z_3 = mult_mod(F, G, p);

        ExtendedHomogeneousPoint { X: X_3, Y: Y_3, T: T_3, Z: Z_3 }
    }
}

impl PartialEqExtendedHomogeneousPoint of PartialEq<ExtendedHomogeneousPoint> {
    fn eq(lhs: @ExtendedHomogeneousPoint, rhs: @ExtendedHomogeneousPoint) -> bool {
        // lhs.X * rhs.Z - rhs.X * lhs.Z
        if (sub_mod(mult_mod(*lhs.X, *rhs.Z, p), mult_mod(*rhs.X, *lhs.Z, p), p.into()) != 0) {
            return false;
        }
        // lhs.Y * rhs.Z - rhs.Y * lhs.Z
        sub_mod(mult_mod(*lhs.Y, *rhs.Z, p), mult_mod(*rhs.Y, *lhs.Z, p), p.into()) == 0
    }
    fn ne(lhs: @ExtendedHomogeneousPoint, rhs: @ExtendedHomogeneousPoint) -> bool {
        !(lhs == rhs)
    }
}

impl PartialEqPoint of PartialEq<Point> {
    fn eq(lhs: @Point, rhs: @Point) -> bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
}
impl SpanU8IntoU256 of Into<Span<u8>, u256> {
    /// Decode as little endian
    fn into(self: Span<u8>) -> u256 {
        if (self.len() > 32) {
            return 0;
        }
        let mut ret: u256 = 0;
        let two_pow_0 = 1;
        let two_pow_1 = 256;
        let two_pow_2 = 65536;
        let two_pow_3 = 16777216;
        let two_pow_4 = 4294967296;
        let two_pow_5 = 1099511627776;
        let two_pow_6 = 281474976710656;
        let two_pow_7 = 72057594037927936;
        let two_pow_8 = 18446744073709551616;
        let two_pow_9 = 4722366482869645213696;
        let two_pow_10 = 1208925819614629174706176;
        let two_pow_11 = 309485009821345068724781056;
        let two_pow_12 = 79228162514264337593543950336;
        let two_pow_13 = 20282409603651670423947251286016;
        let two_pow_14 = 5192296858534827628530496329220096;
        let two_pow_15 = 1329227995784915872903807060280344576;
        ret.low += (*self[0]).into() * two_pow_0;
        ret.low += (*self[1]).into() * two_pow_1;
        ret.low += (*self[2]).into() * two_pow_2;
        ret.low += (*self[3]).into() * two_pow_3;
        ret.low += (*self[4]).into() * two_pow_4;
        ret.low += (*self[5]).into() * two_pow_5;
        ret.low += (*self[6]).into() * two_pow_6;
        ret.low += (*self[7]).into() * two_pow_7;
        ret.low += (*self[8]).into() * two_pow_8;
        ret.low += (*self[9]).into() * two_pow_9;
        ret.low += (*self[10]).into() * two_pow_10;
        ret.low += (*self[11]).into() * two_pow_11;
        ret.low += (*self[12]).into() * two_pow_12;
        ret.low += (*self[13]).into() * two_pow_13;
        ret.low += (*self[14]).into() * two_pow_14;
        ret.low += (*self[15]).into() * two_pow_15;

        ret.high += (*self[16]).into() * two_pow_0;
        ret.high += (*self[17]).into() * two_pow_1;
        ret.high += (*self[18]).into() * two_pow_2;
        ret.high += (*self[19]).into() * two_pow_3;
        ret.high += (*self[20]).into() * two_pow_4;
        ret.high += (*self[21]).into() * two_pow_5;
        ret.high += (*self[22]).into() * two_pow_6;
        ret.high += (*self[23]).into() * two_pow_7;
        ret.high += (*self[24]).into() * two_pow_8;
        ret.high += (*self[25]).into() * two_pow_9;
        ret.high += (*self[26]).into() * two_pow_10;
        ret.high += (*self[27]).into() * two_pow_11;
        ret.high += (*self[28]).into() * two_pow_12;
        ret.high += (*self[29]).into() * two_pow_13;
        ret.high += (*self[30]).into() * two_pow_14;
        ret.high += (*self[31]).into() * two_pow_15;
        ret
    }
}

impl U256IntoSpanU8 of Into<u256, Span<u8>> {
    fn into(self: u256) -> Span<u8> {
        let mut ret = array![];
        let mut remaining_value = self;

        let mut i: u8 = 0;
        while (i < 32) {
            let (temp_remaining, byte) = DivRem::div_rem(remaining_value, TWO_POW_8_NON_ZERO);
            ret.append(byte.try_into().unwrap());
            remaining_value = temp_remaining;
            i += 1;
        };

        ret.span()
    }
}

impl SpanU8IntoU512 of Into<Span<u8>, u512> {
    fn into(self: Span<u8>) -> u512 {
        let half_1 = self.slice(0, SHA512_LEN / 2);
        let half_2 = self.slice(32, SHA512_LEN / 2);
        let low: u256 = half_1.into();
        let high: u256 = half_2.into();

        u512 { limb0: low.low, limb1: low.high, limb2: high.low, limb3: high.high }
    }
}


impl PointIntoExtendedHomogeneousPoint of Into<Point, ExtendedHomogeneousPoint> {
    fn into(self: Point) -> ExtendedHomogeneousPoint {
        ExtendedHomogeneousPoint { X: self.x, Y: self.y, Z: 1, T: mult_mod(self.x, self.y, p) }
    }
}

impl ExtendedHomogeneousPointIntoPoint of Into<ExtendedHomogeneousPoint, Point> {
    fn into(self: ExtendedHomogeneousPoint) -> Point {
        // Check if Z is non-zero
        //if self.Z == 0 {
        //   return Option::None;
        //}

        // Normalize X and Y
        let x = div_mod(self.X, self.Z, p);
        let y = div_mod(self.Y, self.Z, p);

        Point { x, y }
    }
}

/// Function that performs point multiplication for an Elliptic Curve point using the double and add
/// method.
/// # Arguments
/// * `scalar` - Scalar such that scalar * P = P + P + P + ... + P.
/// * `P` - Elliptic Curve point in the Extended Homogeneous form.
/// # Returns
/// * `u256` - Resulting point in the Extended Homogeneous form.
pub fn point_mult(mut scalar: u256, mut P: ExtendedHomogeneousPoint) -> ExtendedHomogeneousPoint {
    let mut Q = ExtendedHomogeneousPoint { X: 0, Y: 1, Z: 1, T: 0 };
    let zero_u512 = Default::default();

    // Double and add method
    while (scalar != zero_u512) {
        if ((scalar.low & 1) == 1) {
            Q = Q + P;
        }
        P = P.double();
        scalar = scalar / 2;
    };
    Q
}

pub fn getG() -> Point {
    Point { x: Gx, y: Gy }
}

/// Function that checks the equality [S]B = R + [k]A'
/// # Arguments
/// * `S` - Scalar coming from the second half of the signature.
/// * `R` - Result of point decoding of the first half of the signature in Extended Homogeneous
/// form.
/// * `k` - SHA512(dom2(F, C) || R || A || PH(M)) interpreted as a scalar.
/// * `A_prime` - Result of point decoding of the public key in Extended Homogeneous form.
/// # Returns
/// * `bool` - true if the signature fits to the message and the public key, false otherwise.
fn check_group_equation(
    S: u256, R: ExtendedHomogeneousPoint, k: u256, A_prime: ExtendedHomogeneousPoint
) -> bool {
    // (X(P),Y(P)) of edwards25519 in https://datatracker.ietf.org/doc/html/rfc7748
    let B: Point = Point {
        x: 15112221349535400772501151409588531511454012693041857206046113283949847762202,
        y: 46316835694926478169428394003475163141307993866256225615783033603165251855960
    };

    let B_extended: ExtendedHomogeneousPoint = B.into();

    // Check group equation [S]B = R + [k]A'
    let lhs: ExtendedHomogeneousPoint = point_mult(S, B_extended);
    let rhs: ExtendedHomogeneousPoint = R + point_mult(k, A_prime);
    lhs == rhs
}

