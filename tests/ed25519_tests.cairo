use alices_ring_cairo_verifier::ed25519::{Point, getG, ExtendedHomogeneousPoint, point_mult};

#[test]
#[available_gas(3200000000)]
fn verify_getG() {
    let G: Point = getG();
    assert_eq!(
        Point {
            x: 15112221349535400772501151409588531511454012693041857206046113283949847762202,
            y: 46316835694926478169428394003475163141307993866256225615783033603165251855960
        },
        G
    );
}

#[test]
#[available_gas(3200000000)]
fn verify_ec_mult() {
    let G = getG();
    let point: Point = point_mult(100, G.into()).into();

    assert_eq!(
        point,
        Point {
            x: 2135193733131445483070106335232343073504389117864377679761312986749504781639,
            y: 29115215761957508369960670020698458660032318370996003643263431019843054043589
        }
    )
}

#[test]
#[available_gas(3200000000)]
fn verify_ec_add() {
    let G: ExtendedHomogeneousPoint = getG().into();
    let point: Point = (G + G).into();
    assert_eq!(
        point,
        Point {
            x: 24727413235106541002554574571675588834622768167397638456726423682521233608206,
            y: 15549675580280190176352668710449542251549572066445060580507079593062643049417
        }
    )
}
