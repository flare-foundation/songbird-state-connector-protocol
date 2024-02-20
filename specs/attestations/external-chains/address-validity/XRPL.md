# XRPL address validity

XRPL has base58 encoded addresses with dictionary: `rpshnaf39wBUDNEGHJKLM4PQRST7VWXYZ2bcdeCg65jkm8oFqi1tuvAxyz`.

An address decoded to hex is of the form: `<leadingByte><publicKeyHash><checkSum>`.
The `leadingByte` on the mainnet is `00` (corresponding to `r`).
The `checksum` is the first four bytes of the double sha256 hash of `<leadingByte><publicKeyHash>`.
The public key hash is 20 bytes long.

## Validation

1. The address contains only characters from the dictionary.
2. The address is 25-35 characters long.
   The address decoded to hex is 25 bytes long.
3. The address starts with a valid leading byte.
4. The address satisfies the checksum condition.

## Relevant documentation

-   [XrplBase58](https://xrpl.org/base58-encodings.html)
-   [Addresses](https://xrpl.org/accounts.html#addresses)

Back: [External chains](/specs/attestations/external-chains.md) |
[DOGE address validity](/specs/attestations/external-chains/address-validity/DOGE.md) |
[Home](/README.md)
