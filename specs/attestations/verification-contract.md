# Verification contract

Once an attestation request is confirmed by the State Connector protocol, its response can be used on Flare Network.
To be used, one must verify that the response is among the confirmed attestations in some voting round.

The following information must be provided for verification:

-   Attestation response.
-   `roundId` of the voting round in which the attestation response was included in the Merkle tree with the confirmed root.
-   Merkle proof of the inclusion of the response.

The verification contract then follows these steps:

-   Fetches the Merkle root for the `roundId` from the [State Connector](/specs/scProtocol/state-connector-contract.md) contract.
-   Calculates the [attestation hash](/specs/attestations/hash-MIC.md#attestation-hash) from the response.
-   Verifies the attestation hash against the Merkle root using the Merkle proof

## Reference implementation

A verification contract implementation can be auto-generated using the [CLI tool](/specs/attestations/cli.md#verification-contracts).

Back: [Attestation Type definition](/specs/attestations/attestation-type-definition.md) |
[Verifier Server](/specs/attestations/verifier.md) |
Next: [Active Types](/specs/attestations/active-types.md) |
[Auto-generation](/specs/attestations/cli.md) |

[Home](/README.md)
