<p align="left">
  <a href="https://flare.network/" target="blank"><img src="https://flare.network/wp-content/uploads/Artboard-1-1.svg" width="400" height="300" alt="Flare Logo" /></a>
</p>

# State Connector protocol

This repository contains the specifications and documentation of the State Connector protocol that is deployed and runs on the **Songbird** blockchain.

## What is the State Connector protocol

State Connector protocol attests data from external blockchains, making it safe to use on the **Songbird** blockchain in a stable and decentralized manner.
The end user requests an attestation of the data by sending a request to the [StateConnector contract](/specs/scProtocol/state-connector-contract.md).
The request is considered by [attestation providers](/specs/scProtocol/attestation-provider.md), who provide the attestation response.
To attest the data, a majority of attestation providers must agree on the response.
To reach an agreement, the request and the response must be well formatted and deterministically defined (with respect to the data available to each attestation provider).
The formats are described by [attestation types](/specs/attestations/attestation-type-definition.md).
A successfully attested response is used to relay data to a smart contract on Songbird in a secure and decentralized manner.

In order to understand how the attestation protocol works, let's consider a simple scenario.
A user proposes a fact to be confirmed by the protocol: "a transaction with ID `XYZ` exists on the Bitcoin network".

Given such an **attestation request**, each attestation provider first attempts to fetch transaction data for the given ID from the Bitcoin network.
Then it extracts information from the transaction data, such as the transaction ID, block number, block timestamp, source address, destination address, transferred amount, payment reference, etc.

The extracted data are assembled into a so-called **attestation response** following a predetermined set of rules.
A 32-byte [**attestation hash**](/specs/attestations/hash-MIC.md#attestation-hash) is then produced using the attestation response and submitted to the protocol.
Several attestation providers do the same in parallel and submit their attestations.

The protocol then collects submitted attestations, and if the majority of the attestations match, the protocol accepts and confirms the majority attestation hash, yielding the **confirmed attestation hash** that is stored on the blockchain.

If in the future, a user provides an attestation response to a contract that requires a payment on Bitcoin to redeem a service on the Flare network.
Such a contract can calculate the hash of the attestation response and compare it to the confirmed attestation hash.
If it matches, the contract would ascertain that the provided attestation response is valid and it can act upon it accordingly.

The State Connector protocol is organized as a sequence of [voting rounds](/specs/scProtocol/voting-protocol.md#voting-rounds).
In each voting round, attestation providers vote not just on a single attestation request but on a package of attestation requests.
The [Merkle root](/specs/scProtocol/merkle-tree.md) of attestation hashes of all confirmed attestation requests in the round is used for voting.
A round is successful if a majority of votes have the same Merkle root.
Voting rounds are a clear analogy of the usual approach to any blockchain consensus algorithm, where validators try to reach consensus not just on a single transaction, but on a package of transactions that are accepted as a block.

### A Use Case

Imagine that the transaction is a payment for some service managed by a contract on the **Songbird** network, for which one needs to pay 1 BTC to a specific Bitcoin address.
In the full workflow, the user would first request the contract for access to the service.
The contract would then issue a requirement to pay 1 BTC to a specified address with a specified payment reference.
The user would carry out a payment on Bitcoin, producing a transaction with transaction ID `XYZ`.
Then it would request the State Connector protocol to attest for the transaction, which would trigger the procedure described above.

If the transaction is confirmed by the State Connector protocol, the user can submit the attestation response data for the `XYZ` transaction to the contract together with the Merkle proof, which shows that the attestation response was indeed among the confirmed attestations.
The contract would check the attestation response data against its requirements (e.g., 1 BTC is required to be sent to the specified receiving address, within the expected time window, with the correct payment reference, etc.).
Then it would calculate the attestation hash of the provided attestation response data and use the provided Merkle proof to compare it against the confirmed Merkle root stored on the [State Connector contract](/specs/scProtocol/state-connector-contract.md).
If everything matches, the contract has a proof that the payment was correct and it can unlock the service for the user.

For a more detailed workflow, see [here](/specs/scProtocol/verification-workflow.md)

## Additional resources

-   [Attestation Client suite](https://github.com/flare-foundation/attestation-client): An implementation of the attestation client according to the specifications.
-   [Multi-Chain-Client](https://github.com/flare-foundation/multi-chain-client): Helper library for data acquisition from the supported chains.
-   [Verifier server template](https://gitlab.com/flarenetwork/verifier-server-template)

## Index

-   [FAQ](/specs/scProtocol/FAQ.md)
-   State Connector Protocol

    -   [State Connector contract](/specs/scProtocol/state-connector-contract.md)
    -   [Verification workflow](/specs/scProtocol/verification-workflow.md)
    -   [Attestation providers](/specs/scProtocol/attestation-provider.md)
    -   [Voting protocol](/specs/scProtocol/voting-protocol.md)
        -   [Bit voting](/specs/scProtocol/bit-voting.md)
        -   [Merkle tree](/specs/scProtocol/merkle-tree.md)
        -   [Branching protocol](/specs/scProtocol/branching-protocol.md)

-   [Attestations](/specs/attestations/attestation.md)

    -   [External chains](/specs/attestations/external-chains.md)

        -   [Standard transaction](/specs/attestations/external-chains/transactions.md)
        -   [Standard payment reference](/specs/attestations/external-chains/standardPaymentReference.md)
        -   [Standard address](/specs/attestations/external-chains/standardAddress.md)

    -   [Global configurations](/specs/attestations/configs.md)
    -   [Attestation type definition](/specs/attestations/attestation-type-definition.md)
        -   [Encoding and decoding](/specs/attestations/encoding-decoding.md)
        -   [Hash, MIC](/specs/attestations/hash-MIC.md)
        -   [Verifier server](/specs/attestations/verifier.md)
        -   [Verification contract](/specs/attestations/verification-contract.md)
        -   [Currently supported types](/specs/attestations/active-types.md)
