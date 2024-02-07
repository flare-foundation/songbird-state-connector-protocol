# Verification workflow

Consider a scenario where we have a smart contract that allows a user to use a service for a payment on the XRPL network.

## Smart contract requirements

The relevant attestation type for this scenario is [Payment](/specs/attestations/active-types/Payment.md), which relays information on a transaction that can be considered as payment.
The contract should implement at least two features:

-   Generation of a request for payment on the XRPL network for the required service (e.g., by calling the function `requestServiceUsage(...)`).
-   Verification of payment proof, and unlocking the service once the payment is confirmed (e.g., the function `provePayment(...)`).

## Usage workflow

### Initiating a request for service usage

The user first needs to call the `requestServiceUsage(...)` function.
The contract then stores a record that a specific `msg.sender` has requested to use the service, and issues a personal 32-byte payment reference for the request.
It returns a request for payment containing:

-   An address on the XRPL network to send funds to.
-   Amount of XRP to be paid.
-   The [payment reference](/specs/attestations/external-chains/standardPaymentReference.md#xrpl). (Alternatively, the payment could be identified by the last digits of the amount to be paid).

### Paying on the XRPL network

After receiving the request for payment, the user can execute a payment on XRPL.
The [payment reference](/specs/attestations/external-chains/standardPaymentReference.md#xrpl) must be correctly included in the transaction.
Once the transaction is confirmed, the user records the transaction ID (e.g., `XYZ`).

### Preparing an attestation request to prove the payment

Next, the user assembles the attestation request for payment according to the [Payment](/specs/attestations/active-types/Payment.md) attestation type.
This includes calculating the [Message Integrity Code](/specs/attestations/hash-MIC.md#message-integrity-code).
The request also has to be correctly [encoded](/specs/attestations/encoding-decoding.md) to get accepted by the [State Connector contract](/specs/scProtocol/state-connector-contract.md).

Alternatively, one can use a [verifier server](/specs/attestations/verifier.md) for the XRPL blockchain provided by one of the attestation providers to assemble and encode the request.
With this method, the MIC is computed automatically.

### Sending the attestation request

The user then submits the encoded attestation request to the State Connector smart contract and waits for the attestation protocol to confirm it.

Depending on the timestamp of the attestation request submission, the [voting round ID](/specs/scProtocol/voting-protocol.md#voting-rounds) (`roundId`) is calculated.

The user waits for about 3 voting windows (4-5 minutes) and monitors the State Connector smart contract to ensure the confirmed [Merkle root](/specs/scProtocol/merkle-tree.md) for the voting round `roundId` is obtained.

### Obtaining the attestation proof

Then the user can query the [REST APIs](/specs/scProtocol/attestation-provider.md#standardized-rest-api-routes) of selected attestation providers to obtain the Merkle proof and attestation response.

The `roundId`, `response`, and `merkleProof` together constitute an attestation proof that can be submitted to a verifying contract.

### Unlocking the service

The user provides the attestation proof to the smart contract (e.g., by calling `provePayment(...)`).
The contract fetches the Merkle root for `roundId`, calculates the hash of the `response`, and uses `merkleProof` to validate the response against the Merkle root.
The validation is implemented in the reference [verification contract](/specs/attestations/verification-contract.md) for each attestation type.
If the response is valid and satisfies the requested criteria (address, amount and payment reference), the smart contract unlocks the service.

## Implementing the smart contract

The smart contract that uses the State Connector protocol has to specify which attestation types it supports and what data (attestation proofs) a user has to provide in order to use the services of the smart contract.

Back: [State Connector contract](/specs/scProtocol/state-connector-contract.md) |
Next: [Attestation provider](/specs/scProtocol/attestation-provider.md) |

[Home](/README.md)
