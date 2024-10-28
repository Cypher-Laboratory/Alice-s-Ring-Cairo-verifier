# Cairo SAG Verifier Library

The **Cairo SAG Verifier Library** provides a high-performance implementation for verifying Spontaneous Anonymous Group (SAG) signatures on Starknet using the Cairo programming language. This library leverages the Garaga MSM (multi-scalar multiplication) and Poseidon hashing function to achieve efficient, Starknet-optimized ring signature verification on SECP256K1 and ED25519 curves.

## Overview

The main functionality of this library is to verify ring signatures by computing the challenges iteratively using Garaga-based MSM operations. The use of the Poseidon hash function reduces computational costs on Starknet compared to traditional hash functions, while MSM and Garaga allow for optimized elliptic curve operations on-chain.

## Key Modules and Functions

### Modules

- **`structType`**: Defines data structures used in SAG signature verification, including `RingSignature` and `GaragaMSMParam`.

### Functions

- **`computeCGaraga`**: Computes the challenge `c` using Garaga's MSM. It handles elliptic curve points in Weierstrass form for ED25519. This function calculates a point by performing MSM on the points provided in the signature hints and returns the next computed challenge by hashing the serialized data with Poseidon.

- **`serializeRing`**: Serializes the `ring` (array of public keys) along with the message digest. This prepares the data for challenge computation by converting each point in the ring and the message digest into `felt252` elements.

- **`verify`**: Main verification function for a ring signature. It iteratively computes the challenges across the ring using the Garaga MSM parameters and checks the validity of each challenge against the next. If all challenges match, the function returns `true`; otherwise, it returns `false`.

## Usage

To use this library, integrate it into your Cairo contract on Starknet to enable on-chain verification of SAG signatures. This involves constructing a `RingSignature` object with the required hints, message digest, and signature data, and passing it to the `verify` function.

### Example Verification Workflow

```cairo
use sag_verifier::verify;
use sag_verifier::structType::RingSignature;

// Assuming `ring_signature` is a populated `RingSignature` struct
let is_valid = verify(ring_signature);

if is_valid {
    // Signature is verified
} else {
    // Verification failed
}
```

