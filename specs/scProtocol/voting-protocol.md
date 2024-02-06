# Voting protocol

The **State Connector protocol** (also known as the Attestation protocol) is a protocol in which facts from external blockchains, or external data sources in general, are proposed for attestation by users.
The set of **default attestation providers** then votes on the proposals by sending attestations.

## Voting rounds and the Merkle root

The State Connector protocol is organized as a sequence of **voting rounds** (or "attestation rounds").
In each voting round, attestation providers vote on a package of attestation requests.

Multiple attestation requests can be collected and put up for vote in a single voting round.
Using a [Merkle tree](/specs/scProtocol/merkle-tree.md), attestation hashes of all verified attestation responses can be assembled into a single hash (the **Merkle root**).
Each attestation provider submits a Merkle root for the voting round.
Proving that a specific attestation is confirmed requires a combination of an attestation response, the confirmed Merkle root, and the specific Merkle proof obtained for the attestation response.

Voting on many requests at once using the Merkle root has its disadvantages.
Even if two attestation providers disagree on only one attestation request, their assembled Merkle roots are completely different.
Hence, even one problematic request can disrupt the agreement on the correct Merkle root for a round.
To mitigate this, the following synchronization and safety mechanisms are applied:

-   [Message Integrity Code](/specs/attestations/hash-MIC.md#message-integrity-code).
    The request has to contain the hash of the expected response, therefore, at most one valid response (up to hash collision) is possible for each request.
-   [Bit voting](/specs/scProtocol/bit-voting.md).
    In the event that the majority of providers cannot confirm an attestation request, the providers that potentially have the data to confirm the request are informed about others' inability and are encouraged not to include the response in the Merkle tree.
    This may happen because a provider is informed about a new block on some chain before the majority is.
-   Commit-reveal scheme.
    The attestation providers are prevented from copying votes (Merkle roots) from other providers.
-   [Lowest used timestamp](/specs/attestations/attestation-type-definition.md#lowest-used-timestamp).
    Attestation providers collectively agree on which data is too old to be used to assemble attestation responses.

### Commit-reveal scheme

A commit-reveal scheme for voting consists of a 2-phase procedure for sending the data in such a way that:

-   In the **commit phase**, one submits **commit data** that contains a proof of the existence of the vote, but does not disclose the vote itself.
    Sending the commit data is possible only during this phase.
    The commit data is a hash of the Merkle root, a random number represented by a 32-byte string to mask the Merkle root, and the sender's address to prevent hash copying.
    The following Solidity code calculates the commit data:

    ```solidity
    keccak256(abi.encode(_merkleRoot, _randomNumber, _address));
    ```

    In Java/Typescript, the `web3-utils` and `@ethersproject/abi` NPM package can be used to assemble the commit data as follows:

    ```typescript
    import { defaultAbiCoder } from "@ethersproject/abi";
    import { soliditySha3 } from "web3-utils";

    soliditySha3(defaultAbiCoder.encode(["bytes32", "bytes32", "address"]), [merkleRoot, randomNumber, address]);
    ```

-   Once the commit phase is finished, the **reveal phase** starts.
    In this phase, the voters can disclose their data (**reveal data**), which should match the **commit data**.
    The reveal data consists of the Merkle root and the random number that were used to calculate the **commit data**.

## Voting rounds

The State Connector protocol is managed by the [State Connector smart contact](/specs/scProtocol/state-connector-contract.md) and [Bit Voting smart contract](/specs/scProtocol/bit-voting.md).
Voting activities are organized using sequential 90-second **voting windows** enumerated by sequential IDs, the `bufferNumbers`.
In each voting window, a new **voting round** starts.
The `roundId` for the voting round is the `bufferNumber` of the starting voting window.

Each round consists of [5 phases](#five-phases-of-a-round) in 4 consecutive voting windows.
Sending the commit-reveal data is carried out only once per voting window, usually seconds before the end.
Note that the voting data consists of commit data for the current round and reveal data for the previous one.
Before the commit-reveal voting, another pre-voting phase is carried out, called the **choose phase**.
This phase is used to agree on which attestations should be put into the Merkle tree while voting in commit-reveal scheme.

### Two sets of attestation providers

In the current implementation of the attestation protocol, the attestation providers are divided into two sets:

-   **Default set**: A selected set of 9 attestation providers that carry out bit voting and commit-reveal voting.
    The accepted hash is defined by the majority Merkle root from the default set.
-   **Local sets**: Each validator or observation node can configure a set of local attestation providers.
    Local sets are used as an additional [security mechanism](/specs/scProtocol/branching-protocol.md).
    A local attestation provider does not have to be a member of the default set.
    Local providers that are not included in the default set do not participate in bit voting.
    Local providers participate in a separate local commit-reveal voting following the bit-voting of the default set, which does not directly influence the default set voting result.
    If a default set confirms a Merkle root that is not supported by a majority in the local set, the node forks out of the network (rejects the Merkle root accepted by the default set) and halts.

### Five phases of a voting round

The breakdown of phases of a voting round is as follows:

1.  `collect`: The first voting phase that starts in a voting window with `bufferNumber` that defines the voting round's `roundId`.
    In this phase, attestation requests are collected.
    As soon as an attestation request is collected, its verification process starts.
2.  `choose`: The first half of the next voting window (`bufferNumber + 1`).
    Before the end of the choose phase, the members of the default set carry out the vote on which attestations requests that were collected in the `collect phase` should be included in the final vote.
    Each member of the default set sends a bit vector with bits corresponding to attestation requests in the order of arrival (with duplicates removed).
    These _bit votes_ are sent to a [Bit voting](/specs/scProtocol/bit-voting.md) contract, which emits them as events.
    Based on the emitted bit votes, each attestation provider can use a deterministic algorithm to calculate the bit-voting result and thereby know which attestations to include in the Merkle tree.
    The calculation is done right after the end of the `choose phase`.
3.  `commit`: The second half of the voting window `bufferNumber + 1`.
    In this phase, attestation providers finish out verifications, assemble the attestations, build the Merkle tree based on the result of the `choose` phase, calculate the Merkle root, and send the **commit data**.
    The **commit data** is sent with the **reveal data** for the previous round (`roundId - 1`).
4.  `reveal`: The next voting window (`bufferNumber + 2`).
    The attestation providers reveal their votes by sending the **reveal data** that matches the submitted **commit data** in the previous voting window.
    The **reveal data** is sent with the **commit data** for the next round (`roundId + 1`).
5.  `count`: Starts immediately after the end of the `reveal` phase, at the beginning of the next voting window (`bufferNumber + 3`).
    In this phase, there are no actions for attestation providers.
    The reveal data sent by each attestation provider is verified against the commit data they sent, thus verifying the validity.
    All Merkle roots are now disclosed.
    The protocol finds the majority Merkle root and declares it the confirmed attestation (confirmed Merkle root).
    The majority threshold is set to 50%+ of all possible votes (the set of all default attestation providers is known in advance).
    If there is no majority Merkle root, the voting round has failed, and no attestation request from that round gets confirmed.
    Users can resubmit attestation requests in later rounds.
    If the round was successful, the confirmed Merkle root is checked against the Merkle root voted by the local set.
    If the roots do not match, the node forks and halts as determined by the [Branching protocol](/specs/scProtocol/branching-protocol.md).

Back: [Attestation Providers](/specs/scProtocol/attestation-provider.md) |
Next: [Bit-voting](/specs/scProtocol/bit-voting.md) |
[Merkle Tree](/specs/scProtocol/merkle-tree.md) |
[Branching protocol](/specs/scProtocol/branching-protocol.md) |
[Attestations](/specs/attestations/attestation.md) |

[Home](/README.md)
