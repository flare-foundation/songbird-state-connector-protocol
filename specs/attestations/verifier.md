# Verifier server

A verifier server should be implemented for every combination of a supported attestation type and chain.
The role of a verifier is to fetch and format data to verify a given attestation request of the supported type following the verification rules of the attestation type.

Every entity is free to implement their own verifiers as long as they follow the rules of the supported attestation type and source.

Ideally an attestation provider also controls the verifier servers, so they can be implicitly trusted.
Alternatively, verifiers can be run by other entities.

## API endpoints

A verifier server should have a standardized API that allows smooth and uniform interaction with attestation clients and end users of the State Connector protocol.
The first (and potentially the second) is primarily designed to be used by the attestation clients.
The rest are targeted to the end user of the State Connector protocol to help with the creation of attestation requests.

-   `POST /verifier/<source>/<attestationType>`

    Tries to verify an [encoded attestation request](/specs/attestations/encoding-decoding.md#encoding) without checking the Message Integrity Code.
    The request data is a JSON with the field `abiEncodedRequest` which should contain the `0x` prefixed [encoded](encoding-decoding.md) attestation request.
    It returns the status of the request (`VALID`, `INVALID`, `INDETERMINATE`) and a response if the status is `VALID`.
    The API response is a JSON with fields `status` and `response` which is the attestation response in JSON whose structure depends on the attestation type of the request.

-   `POST /verifier/<source>/<attestationType>/prepareResponse`

    Tries to verify an attestation request (in JSON) without checking the Message Integrity Code.
    It returns the status of the request (`VALID`, `INVALID`, `INDETERMINATE`) and a response if the status is `VALID`.
    The API response is a JSON with fields `status` and `response` which is the attestation response in JSON whose structure depends on the attestation type of the request.

-   `POST /verifier/<source>/<attestationType>/mic`

    Tries to verify an attestation request (in JSON) without checking the Message Integrity Code.
    If successful, it computes the correct [Message Integrity Code](/specs/attestations/hash-MIC.md#message-integrity-code).
    It returns the status of the request (`VALID`, `INVALID`, `INDETERMINATE`) and the correct MIC if status is `VALID`.
    The API response is a JSON with fields `status` and `messageIntegrityCode`.

-   `POST /verifier/<source>/<attestationType>/prepareRequest`

    Tries to verify an attestation request (in JSON) without checking the Message Integrity Code.
    It returns the status (`VALID`, `INVALID`, `INDETERMINATE`) and the [encodedRequest](encoding-decoding.md) if status is `VALID`.
    The API response is a JSON with fields `status` and `abiEncodedRequest` which is `0x`-prefixed encoding of the request with the correct [Message Integrity Code](/specs/attestations/hash-MIC.md#message-integrity-code).

Back: [Attestation Type definition](/specs/attestations/attestation-type-definition.md) |
[Hash, MIC](/specs/attestations/hash-MIC.md) |
Next: [Verification contract](/specs/attestations/verification-contract.md) |

[Home](/README.md)
