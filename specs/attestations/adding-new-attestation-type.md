# Adding attestation types (WIP)

New attestation types are proposed through [SCIPs](/specs/SCIP/improvement-proposals.md).
A proposal should include:

-   The motivation for the existence of the proposed type.
-   The type description in the form of a [Solidity type definition interface](./attestation-type-definition.md).
    For the template, see [TypeTemplate.sol](/contracts/interface/types/TypeTemplate.sol).
    From the definition file, the documentation markdown file and auxillary configuration files can be generated automatically using [Flare Connector Utils](./cli.md).
-   Reference implementation of the verifier server for the attestation type.
    For that purpose, [Flare Connector Utils](./cli.md) and server template in Typescript can be used.
    The verifier server implementation must support the prescribed [verification API](/specs/attestations/verifier.md).

If the proposal gets enough support from the attestation providers and community, it can be included in the State Connector protocol.

Back: [Attestation Type definition](/specs/attestations/attestation-type-definition.md) |
Next: [Encoding/decoding](/specs/attestations/encoding-decoding.md) |

[Home](/README.md)
