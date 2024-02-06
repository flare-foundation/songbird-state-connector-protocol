# Bitcoin address validity

An address on Bitcoin is derived from the unlocking script (pkscript).

There are two encodings of the [Bitcoin addresses](https://en.bitcoin.it/wiki/Invoice_address).

## Base58

Bitcoin uses the following dictionary for base58 encoding:
`123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz`.

Base58 encoding is case sensitive.

An address decoded to hex is of the form: `<leadingByte><hash><checkSum>`.

-   On mainnet, `leadingByte` is `00` for p2pk and p2pkh addresses and `05` for p2sh addresses.
    On testnet, `leadingByte` is `6f` for p2pk and p2pkh addresses and `c4` for p2sh addresses.
-   `hash` is either public key (p2pk), hash of the public key (p2pkh), or hash of the script (p2sh).
-   The `checksum` is the is the first four bytes of the double SHA-256 hash of the `<leadingByte><hash>`.

### Validation

1. The address contains only characters from the dictionary.
2. The address converted to hex is 25 bytes long (the actual address can be 26 to 34 characters long).
3. The address starts with a valid leading byte.
4. The address satisfies the checksum condition.

### Relevant documentation

-   [BtcBase58](https://en.bitcoin.it/wiki/Base58Check_encoding)
-   [BIP-0013](https://en.bitcoin.it/wiki/BIP_0013)
-   [BIP-0016](https://en.bitcoin.it/wiki/BIP_0016)

## Bech32(m)

Bitcoin uses the following dictionary for bech32 encoding:
`qpzry9x8gf2tvdw0s3jn54khce6mua7l`. An address consists of

-   Human-readable part (HRP): `bc` on mainnet and `tb` on testnet.
-   Separator: `1`.
-   Data part. The first character defines the witness version (0-16).
    The last six characters form a checksum.
    The checksum is defined differently for witness version 0 ([Bech32](https://en.bitcoin.it/wiki/BIP_0173)) and the rest ([Bech32m](https://en.bitcoin.it/wiki/BIP_0350)).

### Validation

1. The address contains only characters from the dictionary.
2. All non-numeric characters are either all uppercase or all lowercase.
3. Address starts with a valid HRP and a separator.
4. The address is long between 14 and 74 characters and its length modulo 8 is 0, 3, or 5.
   Additionally, if the witness version is 0, then the address is 42 or 62 characters long.
5. The address satisfies the checksum according to the witness version.
6. Addresses of witness version 2 and higher are currently not supported and therefore considered invalid.

### Relevant documentation

-   [Bech32](https://en.bitcoin.it/wiki/Bech32)
-   [SegWit](https://en.bitcoin.it/wiki/Segregated_Witness)
-   [BIP-0141](https://en.bitcoin.it/wiki/BIP_0141)
-   [BIP-0173](https://en.bitcoin.it/wiki/BIP_0173)
-   [BIP-0341](https://en.bitcoin.it/wiki/BIP_0341)
-   [BIP-0350](https://en.bitcoin.it/wiki/BIP_0350)

    Back: [External chains](/specs/attestations/external-chains.md) |
    Next: [DOGE address validity](/specs/attestations/external-chains/address-validity/DOGE.md) |
    [Home](/README.md)
