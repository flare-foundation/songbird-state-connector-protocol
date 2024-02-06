# Attestation provider

Attestation providers (from the default set) are the active participants in the attestation process.
Their main roles include:

-   Monitoring and collecting attestation request events emitted by the [State Connector smart contract](./state-connector-contract.md).
-   Monitoring and collecting bit-vote events from [Bit Voting smart contract](bit-voting.md).
-   Assigning attestation requests to the correct [voting rounds](/specs/scProtocol/voting-protocol.md) and [verifying](verifier.md) them.
-   Participating in bit voting through the [Bit Voting smart contract](/specs/scProtocol/contracts/BitVoting.sol).
-   Assembling the [Merkle tree](merkle-tree.md) according to bit-voted and verified requests.
-   Carrying out the commit-reveal voting cycle.
-   Storing the confirmed attestation requests, their responses, and Merkle trees for the rounds with a confirmed Merkle root.
-   Running standardized REST API routes to provide confirmed attestation responses together with Merkle proofs, which can be used on the Flare blockchain.

## Becoming a default attestation provider

Currently, the attestation providers for the default set are chosen by the Flare community and Flare foundation.

## Standardized REST API routes

The attestation provider should also provide a web server (the provider server) that allows accessing information on the submitted attestation requests and voting results.
The following routes have to be supported by attestation providers:

-   `POST /api/proof/get-specific-proof`

    Given `{roundId: number, requestBytes: string}`, a submission of a specific attestation request and the actual byte array of the submitted attestation request (`requestBytes`, a `0x`-prefixed hex string representing the byte array) to the State Connector in the round `roundId`, it returns the JSON response data, which includes the attestation proof, but only if the attestation request was successfully verified in the given round `roundId`.
    The response data contains:

    | Field          | Type   | Description                                                                                                                                                |
    | -------------- | ------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
    | `roundId`      | number | ID of the attestation round in which the request was considered.                                                                                           |
    | `hash`         | string | Hash of the attestation as in the Merkle tree.                                                                                                             |
    | `requestBytes` | string | Encoded attestation request.                                                                                                                               |
    | `response`     | object | Response to the request as specified by the attestation type.                                                                                              |
    | `merkleProof`  | array  | Array of hashes that prove that the request's hash is included in the Merkle tree. It can be an empty array if only one request is confirmed in the round. |

    The data can be used for creating the attestation proofs used on the Flare blockchain.

-   `GET /api/proof/votes-for-round/{roundId}`

    Given a `roundId`, it returns a JSON response containing a list of all attestation objects that were confirmed in the round.
    Each attestation object in the array consists of:

    | Field          | Type   | Description                                                                   |
    | -------------- | ------ | ----------------------------------------------------------------------------- |
    | `roundId`      | number | ID of the attestation round in which the request was considered.              |
    | `hash`         | string | Hash of the attestation as in the Merkle tree.                                |
    | `requestBytes` | string | Encoded attestation request.                                                  |
    | `response`     | object | Response to the request as specified by the attestation type.                 |
    | `merkleProof`  | array  | Array of hashes that prove the request's hash is included in the Merkle tree. |

    It is the same as calling `get-specific-proof` for every confirmed request in the round.

-   `GET /api/proof/requests-for-round/{roundId}`

    Given a `roundId`, it returns a JSON response containing the list of objects describing all attestation requests that were considered in the round.
    Each attestation request object consists of:

    | Field                | Type   | Description                                                  |
    | -------------------- | ------ | ------------------------------------------------------------ |
    | `requestBytes`       | string | Encoded attestation request.                                 |
    | `verificationStatus` | string | Verification status.                                         |
    | `attestationStatus`  | string | Attestation status.                                          |
    | `roundId`            | number | ID of the attestation round in which request was considered. |

    The data can be used for investigating the status of all attestation requests in the round.

-   `GET /api/proof/status`

    Returns an object that includes the current buffer number (voting window ID) and the ID of the latest finalized round.
    The response data contains:

    | Field                    | Type   | Description                                             |
    | ------------------------ | ------ | ------------------------------------------------------- |
    | `currentBufferNumber`    | number | ID of the round that is currently in the request phase. |
    | `latestAvailableRoundId` | number | ID of the latest finished round.                        |

Back: [Verification Workflow](/specs/scProtocol/verification-workflow.md) |
Next: [Voting protocol](/specs/scProtocol/voting-protocol.md) |

[Home](/README.md)
