# Standard external addresses

Each chain has its own specifications for address formats.
The goal is to represent each external address by a uniquely defined string.
In most cases, the address is represented by a case-sensitive string.
When there are more ways of representing an address, some rules are added to make it unique.

## Bitcoin

Bitcoin uses three encodings of addresses; Base58, Bech32, and Bech32m.
Each address has only one encoding.

### Base58

In base58 encoding, an address is a case-sensitive, 25-to-33-character string, containing characters from only `123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz`.

Each Bitcoin address in base58 encoding is considered to be standard.

### Bech32 and Bech32m

These encodings are used for [SegWit](https://en.wikipedia.org/wiki/SegWit) addresses.
The only difference between Bech32 and Bech32m is in the checksum.
For witness version 0, Bech32 is used.
For higher versions, Bech32m is used.
An address starts with the human readable part (hrp) `bc` (`tb` on testnet) and separator `1`, followed by a string containing characters from `qpzry9x8gf2tvdw0s3jn54khce6mua7l`.
The address is not case sensitive; however, the string must not be mixed cased.
The address is between 14 and 74 characters long and its length modulo 8 is 0, 3, or 5.
Additionally, if the witness version is 0, then the address must be 42 or 62 characters long.

A Bitcoin address in Bech32(m) encoding is considered to be standard if it is all lowercase.

## Dogecoin

A Dogecoin address is a case-sensitive, 25-to-33-character string, containing characters from only `123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz`.

Each Dogecoin address encoding is considered standard.

## XRPL

An XRPL address is a case-sensitive 25-to-33-characters-long string, containing characters from only `rpshnaf39wBUDNEGHJKLM4PQRST7VWXYZ2bcdeCg65jkm8oFqi1tuvAxyz`.
Each XRPL address encoding is considered standard.

## Ethereum

An address on Ethereum is an 0x-prefixed 20-bytes hex string.
The actual address is independent of the casing; however, lower and upper cases can be used to define a checksum.
A lowercase address is considered standard.

# Standard address hash

The standard address hash is the `keccak256` hash of the address in the standard form as a string (as in the case of Bitcoin, Dogecoin and XRPL) or `0x`-prefixed hex string (as in the case of Ethereum), in whichever way the address is presented.
The solidity code that computes the standard address hash is:

```Solidity
keccak256(standardAddress);
```

In Type/Javascript, the corresponding hash function is implemented in the _web3.js_ library.
Namely, [web3.utils.soliditySha3](https://web3js.readthedocs.io/en/v1.2.11/web3-utils.html?highlight=sha3#soliditysha3).

```Typescript
web3.utils.soliditySha3(standardAddress);
```

## Examples

### Bitcoin

|                                                                    |
| ------------------------------------------------------------------ |
| 1FWQiwK27EnGXb6BiBMRLJvunJQZZPMcGd                                 |
| 0x8f651b6990a4754c58fcb5c5a11f4d40f8ddfdeb0e4f67cdd06c27f8d7bcbe33 |

|                                                                    |
| ------------------------------------------------------------------ |
| bc1qrmvxmwgqfr5q4fvtvnxczwxwm966n53c4lxh4v                         |
| 0xf75dc4b039ac72e037d67199bb92fa25db32b2210954df99637428473d47cedf |

### Dogecoin

|                                                                    |
| ------------------------------------------------------------------ |
| DL2H9FuaXsxivSs1sRtuJ8uryosyAj62XX                                 |
| 0x51064c88c6b8e9d58b2abeae37a773bf89c9b279f8a05fa0ac0e81ebe13d2f4f |

### XRPL

|                                                                    |
| ------------------------------------------------------------------ |
| rDsbeomae4FXwgQTJp9Rs64Qg9vDiTCdBv                                 |
| 0xa491aed10a1920ca31a85ff29e4bc410705d37d4dc9e690d4d500bcedfd8078f |

### Ethereum

|                                                                    |
| ------------------------------------------------------------------ |
| 0x9ea75d537f8cce61bf1f9227e1dc0f13c71ff93b                         |
| 0x9baaf8fc1f181c970eb780af30727b88d815da447a753112a201642f1bc571c7 |

Back: [External chains](/specs/attestations/external-chains.md) |
[Standard Address](/specs/attestations/external-chains/standardAddress.md) |
Next: [Address Validity](/specs//attestations/external-chains/address-validity.md) |
[Home](/README.md)
