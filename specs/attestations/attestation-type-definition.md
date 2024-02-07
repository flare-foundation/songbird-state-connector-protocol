# Attestation types

**Attestation types** are predefined formats of queries with formatted and typed requests and responses, as well as fully deterministic rules for how to provide responses.
Each attestation considered by the State Connector protocol has to follow the rules set for its type.
The response is used to verify the request.

## Attestation type definition

The definition of an attestation type requires three components:

-   Request format.
-   Response format.
-   Verification rules.

Request and response formats are provided by Solidity struct types.
Verification rules are clear deterministic instructions on how the response is constructed.
The components must be assembled into a Solidity file as described by the [Type template](/contracts/interface/types/TypeTemplate.sol).
The file must be fully commented with verification rules included.

An attestation type must be defined in a way that the expected response is unambiguous (with respect to the data available to the provider).
A unique response is extremely important due to the representation of the submitted votes by the Merkle root of all attestation responses in the voting round.
Although the [Message Integrity Code](hash-MIC.md#message-integrity-code) (MIC) makes only one response valid (up to hash collision), a case of a single request with two equally likely responses (one validated by MIC, one not) could make it difficult to agree on a single Merkle root with more than 50% of votes.

## Attestation type ID

Each attestation type has a name, for example, [Payment](/specs/attestations/active-types/Payment.md).
It also has an attestation type ID, a `0x`-prefixed, 32-byte, lowercase hex string, derived from its name.
The ID of the type is utf-8 hex encoding of the name (without trailing blank spaces) padded with zeros on the right to 32-bytes.
Hence, an attestation type name can be at most 32 characters long.

For example, the ID of attestation type `Payment` is `0x5061796d656e7400000000000000000000000000000000000000000000000000`.

## Request format

The request format for an attestation type is defined by a Solidity struct:

```Solidity
struct Request {
    bytes32 attestationType;
    bytes32 sourceId;
    bytes32 messageIntegrityCode;
    RequestBody requestBody;
}

```

| Field                  | SolidityType  | Description                                                                                              |
| ---------------------- | ------------- | -------------------------------------------------------------------------------------------------------- |
| `attestationType`      | `bytes32`     | [ID](#attestation-type-id) of the attestation type as defined .                                          |
| `sourceId`             | `bytes32`     | [ID](/specs/attestations/external-chains.md#source-id) of the source chain.                              |
| `messageIntegrityCode` | `bytes32`     | [`MessageIntegrityCode`](hash-MIC.md#message-integrity-code) that is derived from the expected response. |
| `requestBody`          | `RequestBody` | Data defining the request. Type (struct) and interpretation are determined by the `attestationType`.     |

All fields are mandatory.

## Response format

The response format for an attestation type is defined by a Solidity struct:

```Solidity
struct Response {
    bytes32 attestationType;
    bytes32 sourceId;
    uint64 votingRound;
    uint64 lowestUsedTimestamp;
    RequestBody requestBody;
    ResponseBody responseBody;
}
```

| Field                 | SolidityType   | Description                                                                                                                                              |
| --------------------- | -------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `attestationType`     | `bytes32`      | Extracted from the request.                                                                                                                              |
| `sourceId`            | `bytes32`      | Extracted from the request.                                                                                                                              |
| `votingRound`         | `uint64`       | The ID of the State Connector round in which the request was considered. This is a security measure to prevent collision of attestation hashes.          |
| `lowestUsedTimestamp` | `uint64`       | The timestamp of the earliest data (block) needed to assemble the `responseBody`.                                                                        |
| `requestBody`         | `RequestBody`  | Extracted from the request.                                                                                                                              |
| `responseBody`        | `ResponseBody` | Data defining the response. The verification rules for the construction of the response body and the type are defined by the specific `attestationType`. |

All fields are mandatory.

## Lowest used timestamp

This is the lowest timestamp of the data used to assemble the response.
Each attestation type definition needs to deterministically define how `lowestUsedTimestamp` is calculated for an attestation response.
If an attestation type does not use any timestamped data to generate the response, the default value of `lowestUsedTimestamp` is $2^{64}-1$ or `0xffffffffffffffff` in hex (the greatest number that can be described by a variable of the type `unit64`).

This is currently unused, but ready for the future improvements.

Back: [Attestations](/specs/attestations/attestation.md) |
[External chains](/specs/attestations/external-chains.md) |
Next: [Adding new attestation type](/specs/attestations/adding-new-attestation-type.md) |
[Currently supported attestation types](./active-types.md) |

[Home](/README.md)
