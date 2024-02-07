# Doge address validity

Doge uses the following dictionary (same as Bitcoin) for base58 encoding:
`123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz`.

An address decoded to hex is of the form: `<leadingByte><hash><checkSum>`.

-   On mainnet, `leadingByte` is `1e` for p2pk and p2pkh addresses and `16` for p2sh addresses.
    On testnet, `leadingByte` is `6f` for p2pk and p2pkh addresses and `71` for p2sh addresses.
-   `hash` is either public key (p2pk), hash of the public key (p2pkh) or hash of the script (p2sh).
-   `checkSum` is the is the first four bytes of double SHA-256 hash of the `<leadingByte><hash>`.

## Verification

1. The address contains only characters from the dictionary.
2. The address is 26-34 characters long. The address in hex is 25 bytes long.
3. The address starts with a valid leading byte.
   As a consequence, the fist letter of the address on mainnet can only be `D`, `A`, or `9` (`n`, `m`, or `2` on testnet).
4. The address satisfies the checksum.

Back: [External chains](/specs/attestations/external-chains.md) |
[BTC address validity](/specs/attestations/external-chains/address-validity/BTC.md) |
[Home](/README.md)
