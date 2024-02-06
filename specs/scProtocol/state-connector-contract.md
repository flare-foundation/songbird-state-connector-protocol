# State Connector contract

The [State Connector smart contract](/specs/scProtocol/contracts/StateConnector.sol) is used to manage the attestation protocol.
It is a voting contract that does the following:

-   Continuously accepts encoded attestation requests and emits events that contain the encoded attestation request and timestamp.
    The contract does not keep track of any data related to attestation requests.
    Matching attestation requests to the correct [voting rounds](/specs/scProtocol/voting-protocol.md#voting-rounds) is done by attestation providers according to the timestamps of the emitted events.
-   Accepts commit and reveal submissions by attestation providers, mapping them to the correct voting windows, consequently mapping them to the correct [commit and reveal phases](/specs/scProtocol/voting-protocol.md#five-phases-of-a-round) of the voting rounds.
-   Counts the votes (Merkle roots) and declares a potential confirmed Merkle root for every voting round (in the `count` phase).
-   Stores the confirmed Merkle roots for one week.

Voting rounds are interlaced.
For example, if _W<sub>0</sub>_, _W<sub>1</sub>_, ... are sequential 90s voting windows, then the voting round with ID `0` has its `collect` phase in _W<sub>0</sub>_, the `commit` phase in _W<sub>1</sub>_, the `reveal` phase in _W<sub>2</sub>_, and the `count` phase in _W<sub>3</sub>_.
Simultaneously, the voting round with ID `1` has its `collect` phase in _W<sub>1</sub>_, the `commit` phase in _W<sub>2</sub>_, and the `reveal` phase in _W<sub>3</sub>_.

Additionally, the data submitted by attestation providers for voting rounds is interlaced; the data sent in window _W<sub>n</sub>_ contains commit data for `roundId = n - 1` and reveal data for `roundId = n - 2`.

## Requesting attestations

An attestation request is sent as a byte string, which [encodes](/specs/attestations/encoding-decoding.md#encoding) the request data according to the rules of each attestation type.
This byte string is sent to the `StateConnector` contract using the following function:

```solidity
function requestAttestations(bytes calldata data) external;
```

This is a very simple function.
All it does is emit the event that includes `block.timestamp` and submitted attestation request data.

```solidity
event AttestationRequest(
   uint256 timestamp,
   bytes data
);
```

Attestation providers assign each emitted request to the voting round that is in the collect phase at the time of the emission.
The `roundId` for a request can be computed as follows:

```solidity
roundId = (timestamp - BUFFER_TIMESTAMP_OFFSET) / BUFFER_WINDOW
```

where `BUFFER_TIMESTAMP_OFFSET` and `BUFFER_WINDOW` are defined in the [State Connector smart contract](/specs/scProtocol/contracts/StateConnector.sol).

A submitted request is not stored on the blockchain.

## Providing attestations

Attestation providers listen for the emitted `AttestationRequest` events.
They collect all the requests, match them to the voting rounds according to the timestamp, parse them, and figure out what kind of verifications they need to carry out.
For each successfully validated request, the attestation response is calculated, and from it the attestation hash.
All the attestation hashes for the round are collected into a [Merkle tree](./merkle-tree.md), and the Merkle root for the round is thus obtained.

An attestation provider uses a single function on the `StateConnector` contract for submitting and revealing its vote in a commit-reveal scheme:

```solidity
function submitAttestation(
   uint256 bufferNumber,
   bytes32 commitHash,
   bytes32 merkleRoot,
   bytes32 randomNumber
) external returns (
   bool _isInitialBufferSlot
)
```

This function is called once per voting window, usually near the end of it.
By calling this function, one simultaneously sends commit data for the current voting round (`commitHash`) and reveal data for the previous voting round (`merkleRoot`, `randomNumber`).
The commitHash is computed by the following.

```solidity
keccak256(abi.encode(_merkleRoot, _randomNumber, _address));
```

The `StateConnector` smart contract operates with sequential 90s time windows (`BUFFER_WINDOW = 90`).
Here `bufferNumber` indicates the index of a particular window.
Given a timestamp `T`, one can calculate the corresponding `bufferNumber` for `T` as follows:

```solidity
bufferNumber(T) = (T - BUFFER_TIMESTAMP_OFFSET) / BUFFER_WINDOW
```

The voting round ID is the `bufferNumber` of the window in which the voting round started.

The caller of the `submitAttestation` function must call it with the `bufferNumber` corresponding to the time of the call.
Otherwise, the call is rejected.

Accordingly, calling `submitAttestation` in a given voting window with the `bufferNumber` implies sending commit data for `roundId` equal to `bufferNumber - 1` and the reveal data for the `roundId` equal to `bufferNumber - 2`.

## Default attestation provider set

The attestation providers from the default set are the only providers that have the right to vote on an attestation request.
In addition, each node can have its own local set that is tasked to supervise the default set.
Disagreements are managed by the [Branching protocol](/specs/scProtocol/branching-protocol.md).

Currently, there are 9 community-selected members in the default set. The set will expand going forward, with the community deciding on any new inclusions.

## Confirmed Merkle roots

In the `count` phase, the `StateConnector` verifies `commit data` against `reveal data` and counts the occurrences of Merkle roots submitted by the default set.
If the same Merkle root value is submitted by more than 50% of attesters in the default set, the `StateConnector` emits it as the `confirmed Merkle root` of the voting round.
To help reach consensus, [Bit Voting](bit-voting.md) is used.

In the current implementation, the confirmed Merkle root value is accessible by looking up the public array `merkleRoots` in the contract, which is a cyclic buffer of length `TOTAL_STORED_PROOFS` (6720, a week of proofs).
The proof for a given voting round `roundId` is stored at the index `roundId % TOTAL_STORED_PROOFS`.

## State Connector contract deployments

The currently deployed `StateConnector` contracts on Songbird network is available at the following addresses:

-   https://songbird-explorer.flare.network/address/0x0c13aDA1C7143Cf0a0795FFaB93eEBb6FAD6e4e3

Do not relay on the provided address. Retrieve the address from chain using [FlareContractRegistry](https://docs.flare.network/dev/getting-started/contract-addresses/).

The contract have the start timestamp set as the Unix epoch `BUFFER_TIMESTAMP_OFFSET = 1636070400` (November 5th, 2021) and `BUFFER_WINDOW = 90`.

Next: [Verification workflow](/specs/scProtocol/verification-workflow.md) |

[Home](/README.md)
