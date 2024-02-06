# Ethereum address validity

There are two types of addresses on Ethereum - addresses of externally owned accounts (EOA) and contract addresses.

The address of an EOA on Ethereum is the `0x`-prefixed last 20 bytes of the keccak256 hash of the public key.
The actual address is case insensitive; however, lower and upper cases can be used to define a checksum.

## Verification

1. The address is in hex.
2. The address is 20 bytes long.

## Relevant documentation

-   [Checksum](https://eips.ethereum.org/EIPS/eip-55)

Back: [External chains](/specs/attestations/external-chains.md) |
[XRPL address validity](/specs/attestations/external-chains/address-validity/XRPL.md) |
[Home](/README.md)
