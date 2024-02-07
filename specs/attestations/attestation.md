# Attestations

The State Connector protocol transfers data from [external blockchains](./external-chains.md) in the form of attestations.

An attestation consists of an attestation request and response.
Their format is defined by its [attestation type](/specs/attestations/attestation-type-definition.md).
The attestation type also defines how a response to the request should be assembled.
Usually the response is created using a designated [verifier server](/specs/attestations/verifier.md).

An attestation is considered valid if its hash is included in the Merkle tree that is confirmed in a voting round.
An attestation together with the Merkle proof of inclusion can be used by smart contracts on the Songbird Network.

Next: [External Chains](./external-chains.md) | [Attestation Type Definition](/specs/attestations/attestation-type-definition.md) |

[Home](/README.md)
