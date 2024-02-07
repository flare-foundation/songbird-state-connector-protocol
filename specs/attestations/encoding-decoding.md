# Encoding and decoding

Attestation requests need to be encoded before sending them to the State Connector contract and attestation responses need to be encoded before hashing them.
The encoding is specified by [ABI encoding](https://docs.soliditylang.org/en/latest/abi-spec.html) in Solidity.

## Solidity

The encoding of the [request](attestation-types-definition.md#request-format) is done by Solidity abi.encode:

```Solidity
abi.encode(request)
```

and decoding is done by Solidity abi.decode:

```Solidity
abi.decode(encodedRequest, Request)
```

where `Request` is the struct type defined by the attestation type of the request.

Back: [Attestation Type definition](/specs/attestations/attestation-type-definition.md) |
Next: [Hash, MIC](/specs/attestations/hash-MIC.md) |

[Home](/README.md)
