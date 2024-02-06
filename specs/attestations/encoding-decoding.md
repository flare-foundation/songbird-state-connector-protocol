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

## Typescript

When using Javascript or Typescript to interact with the State Connector protocol, requests and responses are typically represented by JSON files.
Encoding and decoding in Javascript/Typescript can be done using `defaultAbiCoder` from the [`@ethersproject/abi`](https://www.npmjs.com/package/@ethersproject/abi) NPM package and JSON ABI definitions.

### Obtaining JSON ABI

Each attestation type comes with the type definition contract in a Solidity file that defines relevant request and response structs.
It is recommended to use configuration files with ABI definitions generated from Solidity interfaces with attestation definitions.
The ABI definitions can be generated using [Flare Connector Utils](../cli.md) tool.
Extended attestation type configurations with JSON ABI definitions (a.k.a. extended configs) are provided within the generated JSON files in the `generated/configs` folder.

### Encoding and decoding utility

For a convenient encoding and decoding, a utility class [`AttestationDefinitionStore`](../../libs/ts/AttestationDefinitionStore.ts) is used.
The class constructor requires a path to the folder with extended configs.
The path is provided as an absolute path or it is relative to the working directory of the running program.
The class provides the following functionalities:

-   `extractPrefixFromRequest(reqBytes)`: Extracts the attestation type, source ID, message integrity code and the ABI encoded body from the attestation request `reqBytes` provided as a byte sequence represented as a `0x`-prefixed hex string.
    This is a static function, which does not need awareness of any specific configs.
-   `encodeRequest(request: ARBase)`: Encodes an attestation request into a `0x`-prefixed hex string (byte sequence), that can be sent to the State Connector contract as an attestation request.
    The request should be provided in a JSON structure matching the expected struct in the definition of the relevant attestation type (obtained from the relevant extended config).
-   `parseRequest(bytes)`: Decodes the `0x`-prefixed hex string representing an attestation request into the parsed JSON object matching the relevant request structure defined for a specific attestation type.
    Parsing is based on ABI definitions in the specific extended config for the attestation type, as extracted from the request.
-   `attestationResponseHash(response, salt?)`: Produces the prescribed hash of the attestation request. This involves proper ABI encoding of the request, possibly appending the salt (if provided; type of salt is string), yielding a byte sequence that gets hashed with the `keccak256` hash function.
-   `equalsRequest(request1, request2)`: Compares two JSON objects to determine if they are deeply equal. A specific extended configuration is used in comparison.

### Encoding and decoding implementation details

Encoding requests or responses in Typescript is implemented as follows.
Extended configs for an attestation type include JSON ABI definitions for requests and responses in the fields `requestABI` or `responseABI`, respectively.
Given the `abi` object from the JSON ABI definition for the request or response, encoding and decoding is done as follows:

```Typescript
import { defaultAbiCoder } from "@ethersproject/abi";
const encoded = defaultAbiCoder.encode([abi], [data]);
```

Decoding requests and responses is done in a similar manner.

```Typescript
import { defaultAbiCoder } from "@ethersproject/abi";
const decoded = defaultAbiCoder.decode([abi], [encodedData]);
```

where `encodedData` is the a `0x`-prefixed string that represents the encoded ABI data to be decoded.

### Alternative method

In addition, an alternative option, which is not well documented, is to use _web3.js_ library and functions [web3.eth.abi.encodeParameter](https://web3js.readthedocs.io/en/v1.2.11/web3-eth-abi.html#encodeparameter) and [web3.eth.abi.decodeParameter](https://web3js.readthedocs.io/en/v1.2.11/web3-eth-abi.html#decodeparameter).
For this function, `abi` and `data` (`encodedData` respectively), have to be provided directly, not in an array.
These functions are wrappers with some additional functionalities around functions from [`@ethersproject/abi`](https://www.npmjs.com/package/@ethersproject/abi) NPM package.

Back: [Attestation Type definition](/specs/attestations/attestation-type-definition.md) |
Next: [Hash, MIC](/specs/attestations/hash-MIC.md) |

[Home](/README.md)
