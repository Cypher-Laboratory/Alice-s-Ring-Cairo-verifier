use hello_world::structType::{RingSignature, Curve};
use hello_world::ed25519::{Point, getG, ExtendedHomogeneousPoint, point_mult};
use hello_world::verify;

#[test]
#[available_gas(3200000000000000)]
fn test_verify() {
    let ring = array![
        Point {
            x: 3893174053425306424117375407520544656297488477663722909837020641206098973391,
            y: 10657495649227650482807288028275287879965920379530753533351072332674903396550
        },
        Point {
            x: 6107302457790937030327048164688757732280534443875700374495443182748604050900,
            y: 34408208267190262510609719821648603367379423696147372401733970751195464215177
        },
        Point {
            x: 12632649521979515847074621573423552169605289341059568778318795647621181984806,
            y: 25532149091352286430307180900301885225921841363939904958011540612962878155828
        },
        Point {
            x: 18692818425924056284077361575286289503472634786144083983260241244353871635402,
            y: 25130982270725351492078080917244946694662105954296899228585440574429183004137
        },
        Point {
            x: 33986058871552910568651101907306172507889709170681037066031913599284247780616,
            y: 50465964246956439513629485026616137077907893571903418330307354468252175739185
        },
        Point {
            x: 34250097212016581878378510908860304659817170299998157208466736831067993284316,
            y: 31501100563447797089370444184875303192304610195273019347825025349024727370472
        },
        Point {
            x: 34672500250231389686957354902388598831880703419176689686148360288900932404486,
            y: 22349926047418830863286868424047153664031984048551566879408141024670517963814
        },
        Point {
            x: 42842387760493112530676102174093953923720205663258176845113463243151461946695,
            y: 31521397850261351514215762853960690202016064460811530235485016346110580060958
        },
        Point {
            x: 46640161094862498887319267513742142879314874626693768022545102539393170313856,
            y: 29281598888376043924944403887350209383198193855627819911092056030887793472672
        },
        Point {
            x: 48169412611588166984974777690414649405854263266503341677790055577130847749086,
            y: 35304555330307088563378989364011432108154408245338297158206561833203829092972
        },
        Point {
            x: 49404436312376245740331424175997760154821311870367152283055490490749843900420,
            y: 36407112948267700815706237961212238366155814822320393324467842672799158956408
        }
    ];
    let ringSign = RingSignature {
        message: 1952805748,
        c: 12384772147680145670991548981086330334365850861716801366911182343222431156,
        responses: array![
            6920914941777638969890955582217259756651897583562097098192725221964896110019,
            2056344570568092663071963792811143750322102645965661663043211308080883573985,
            1379962449784642202846898903822668824389281910650763014708981494878797777008,
            4545576691054043752917220763159844427194800330212214217822155225034952046578,
            1739685992538888152892907474863095806977644415077043175558487255833705084578,
            3826927193725625325621500107815153546839379510017450260042565556128740380690,
            3948444039455100560333824298383708809872452595056730955873147899470045912213,
            4322913445514219832311859081226036783675548051953023764227874110702129855115,
            1774985518641602081674045771184084460005706184491697889190222488985748282556,
            3074084855853152799995140961325685586812473030395924879678314511342433802277,
            2485988207421031904747310307598922277384409516652594272447876511623537652568
        ],
        ring: ring
    };

    let verif = verify(ringSign);
    println!("signature is valid ? {:?} ", verif);
    // Add your test assertions here
// For example:
// assert(verify(ringSign), 'Verification should pass');
}
