# FAQ

## What is the State Connector protocol?

The State Connector protocol is a request-response-based protocol that supports providing data and facts from external blockchains and other data sources in a trustless and decentralised manner.
It runs on all Flare Networks (Songbird, Flare, Coston, and Coston2) and is managed by the [State Connector contract](/specs/scProtocol/state-connector-contract.md).

## Why would I need the State Connector protocol?

One example is that you can implement a smart contract on Songbird, which acts upon the proof that someone made a specified payment on the Bitcoin network. For example, someone can pay on the Bitcoin blockchain to buy a NFT on Songbird.
Once the payment is made, the State Connector protocol can be used to prove the payment to the NFT smart contract on the Flare Network, which would than automatically mint the NFT.

Another example would be that you require a specific payment in XRPL up to a certain timestamp to release collateral on Songbird.
The State Connector protocol can be used to prove that the payment was made by the due date and the collateral can be released, or it can be used to prove that the payment was not carried out by the due date and the proof can be used to liquidate the collateral.

The State Connector protocol allows for extensions to the types of proofs and blockchain data sources in the form of new attestation types.
Once those are introduced, they can be used for new use cases.

## How can the State Connector protocol be used?

To prove a given fact, we create an attestation request following the rules of the chosen [attestation type](/specs/attestations/attestation-type-definition.md).

The request is then encoded into the byte sequence and submitted to the [State Connector smart contract](/specs/scProtocol/state-connector-contract.md).
After 3-5 minutes (one [voting round](/specs/scProtocol/voting-protocol.md#voting-rounds)), the request is either confirmed or not (together with other requests in the same attestation round).
Checking whether the attestation request was proven and obtaining the proof data can be carried out through REST API routes from [attestation providers](/specs/scProtocol/attestation-provider.md).

The Merkle roots of the successful attestation rounds are stored in the State Connector smart contract.

Once the proof data is obtained, it can be submitted to a smart contract that can verify the proof against the Merkle root of the round and act upon the provided data.

## What is an attestation request?

An [attestation request](/specs/attestations/attestation-type-definition.md#request-format) is a type of formatted and parametrized query submitted to the [State Connector smart contract](/specs/scProtocol/state-connector-contract.md) with the goal of proving certain data or facts from an external data source.
A simplified example of an attestation request is _"confirm that a certain payment is confirmed on the Bitcoin chain"_.
Such an attestation request triggers validation of the query by [attestation providers](/specs/scProtocol/attestation-provider.md) in a decentralized manner.
If the query gives a positive response, the data called attestation responses are produced and attested to by each attestation provider.

## What is an attestation response?

An attestation response is the reply to an attestation request.
It is obtained in the process of verification of an attestation request.
The response to a valid attestation request must be uniquely defined.
How a response is obtained and formatted is unambiguously defined by the[attestation type](/specs/attestations/attestation-type-definition.md) of the request.
A attestation response that is validated by the State Connector protocol can be safely used on the Flare blockchain.

## Which kinds of attestation requests can the State Connector system currently process?

Attestation requests must follow certain predefined rules defined by an [Attestation type](../attestation-objects/attestation-types-definition.md).
There are numerous already [supported types](/specs/attestations/active-types.md).
New attestation types can be added, if a consensus among attestation providers is reached.

## How can I form an attestation request?

Attestation request is formed by [encoding](/specs/attestations/encoding-decoding.md#encoding) the [attestation request](/specs/attestations/attestation-type-definition.md#request-format) (usually in JSON) that satisfies the rules of the chosen attestation type.

## Which generic fields does each attestation request have?

Each [attestation request](/specs/attestations/attestation-type-definition.md) in JSON or Solidity `struct` form has three mandatory fields:

-   `attestationType`: a `0x`-32-byte string, ID the attestation type.
-   `sourceId`: a `0x`-32-byte string, ID the source of the data pertaining to the request.
-   [`messageIntegrityCode`](/specs/attestations/hash-MIC.md#message-integrity-code): a `0x`-prefixed 32-byte string, a hash calculated from the expected attestation response.

## What is a Message Integrity Code (MIC)?

The [Message Integrity Code](/specs/attestations/hash-MIC.md#message-integrity-code) is a mandatory field for every attestation request. It is derived from the expected response.
It ensures that at most one (up to hash collision) attestation response is valid for each attestation request as the response has to match the MIC.

## How to submit an attestation request?

Attestation requests should be submitted in the [encoded](/specs/attestations/encoding-decoding.md#encoding) form to the [State Connector smart contract](/specs/scProtocol/state-connector-contract.md) on Songbird using the function:

```solidity
function requestAttestations(bytes calldata _data) external;
```

The `_data` parameter is the `0x`-prefixed encoded attestation request.

## What happens after I submit an attestation request?

If the transaction calling the `requestAttestations(...)` function on the [State Connector smart contract](/specs/scProtocol/state-connector-contract.md) is successful, the attestation request is submitted and emitted to the attestation providers.
It is important to read out the transaction's timestamp from the blockchain, since the timestamp determines the voting round ID to which the transaction is submitted (see the question below).

A successfully submitted transaction triggers validation of the attestation request by attestation providers.
The result of validation is available in 3 to 5 minutes.

### In which round was my attestation request considered?

Based on the block timestamp of the attestation request transaction, the attestation request gets assigned to a voting round (`roundId`).
By reading the variables `BUFFER_TIMESTAMP_OFFSET` and `BUFFER_WINDOW` from the [State Connector](/specs/scProtocol/contracts/StateConnector.sol) smart contract, the `roundId` is calculated from the transaction's `block.timestamp` as follows:

```solidity
roundId = (block.timestamp - BUFFER_TIMESTAMP_OFFSET) / BUFFER_WINDOW
```

Note that `block.timestamp` is in seconds on Songbird, thus it is an integer number.
The division in the formula above is integer division (i.e., floor division, dropping the decimal places and taking the lower number).

## Who are attestation providers?

[Attestation providers](/specs/scProtocol/attestation-provider.md) are external entities that verify attestation requests by looking into data on relevant external data sources or blockchains.
Verification is done by each attestation provider independently in a decentralized manner.
Each attestation provider also provides REST API routes that can be used to obtain attestation proofs, monitor attestation request progress, and help in forming correct attestation requests.

## Do I submit an attestation request to an attestation provider?

No. Submitting attestation requests is only possible through Songbird network, using the `requestAttestations(...)` function on the [State Connector smart contract](/specs/scProtocol/state-connector-contract.md).

## How do I get a proof for the submitted attestation request?

If the attestation request was successfully validated, two pieces of data help you find the proof data.

When you submit an attestation request, take note of these two pieces of data:

    - The byte encoded attestation request.
    - The `roundId` in which the attestation request was submitted.

If the attestation request is confirmed, any attestation provider that voted correctly has the response and the proof that the request is included in the Merkle tree.
In order to obtain the response and the proof, REST API routes on attestation provider servers need to be queried.

## How do I assemble an attestation proof for use with the verifying smart contract?

An attestation proof consists of the following data:

-   [`roundId`](/specs/scProtocol/voting-protocol.md#voting-rounds) of the attestation request.
-   [Attestation response](/specs/attestations/attestation-type-definition.md#response-format), which consists of the data about the result of the attestation request, in the form as described in the definition of each [attestation type](/specs/attestations/attestation-type-definition.md).
-   [Merkle proof](/specs/scProtocol/merkle-tree.md#building-a-merkle-proof).

The data for assembling the proof can be obtained from the [attestation providers](/specs/scProtocol/voting-protocol.md#two-sets-of-attestation-providers) off-chain.

## To which smart contract can or should I submit the attestation proof?

This depends on the dApp that uses the State Connector protocol to allow certain actions based on a successful proofs.
A smart contract that uses attestation proofs should specify which attestation type is required and what data should be provided.
After the proof is submitted, the contract should use a [verification contract](/specs/attestations/verification-contract.md) for the attestation type to check that the proof is valid and the response can be trusted.
An implementation of a verification contract can be generated with [Flare Connector Utils](/specs/attestations/cli.md) tool.

## How can I implement a dApp that uses proofs for a State Connector system?

For easier understanding, see an [example attestation verification workflow](/specs/scProtocol/verification-workflow.md).

## How can I add a new attestation type?\

There is a standardized [process](/specs/attestations/adding-new-attestation-type.md) of adding new attestation types to the protocol.

[Home](/README.md)
