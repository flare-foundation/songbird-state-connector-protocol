# Bit voting

Bit voting is a technique used to resolve ambiguous attestation requests.
It is managed by the [Bit voting smart contract](/specs/scProtocol/contracts/BitVoting.sol).

Because the availability of data from a specific data source may vary, it can happen that not all data providers can confirm certain transactions or facts at any given time.
For example, a transaction may be in a recent block, which is visible to some of the attestation providers but not yet to the majority.
If there was a request needing such data, the more up-to-date provider would vote with a different root than the majority.
Bit voting is used to eliminate such requests.

Since 50%+ of attesters have to submit the same Merkle root for it to be confirmed, more than 50% of votes must be identical on all requests.
Ambiguous decision requests can therefore disrupt the attestation process, resulting in several different non-majority Merkle roots being submitted.
To sync the attestation providers on what can be jointly confirmed, the [**choose phase**](/specs/scProtocol/voting-protocol.md#five-phases-of-a-round) of the attestation protocol is used.
It is called bit voting because each attestation provider votes on how they want to attest using one bit for each request.

Here is how the choose phase works for bit voting: After collecting attestation requests, each attester enumerates the requests in order of arrival (omitting duplicates) and tries to verify them.
To each request a bit is assigned; a `1` for _can verify_ or a `0` for _cannot verify_.
Assigned bits are stored into a bit array called `bitVote`, which is sent to the [Bit Voting smart contract](/specs/scProtocol/contracts/BitVoting.sol).

Attestation providers use the `submitVote` method from the `BitVoting` contract to emit their vote in the **choose phase**.
The first byte of the `bitVote` is calculated from the intended voting round for which the bit voting is carried out.
The first byte must be `roundId % 256` to be considered a valid vote.
If an attester submits several votes for one round, the last valid vote sent before the deadline is considered valid.

Attesters can listen to the emitted `bitVotes` and use a deterministic algorithm to determine a "good" subset of chosen requests such that enough attesters from the default set have the data to respond to all requests in the subset.
Then attestation providers only validate (include into the Merkle tree) the chosen requests.

Currently, `StateConnector` has a default set of 9 attestation providers.
At least five equal votes are required to confirm a Merkle root.
The calculation of the bit voting result proceeds as follows:
Based on the fixed order of the attestation providers, all the subsets-of-5 of the default set are enumerated.
For each subset-of-5, the requests that members of the subset can all confirm are determined (the request for which all members of the set bit voted with `1`).
The voting result is determined by the subset-of-5 that can collectively confirm the most requests.
If more subsets-of-5 can confirm the same number of requests, the first according to the enumeration defines the result.
The algorithm is used by each attestation provider separately.

After the bit vote, an attestation provider should either:

-   Assemble the Merkle tree that includes the exact hashes of attestations for the requests in the subset chosen by bit voting, and submit the Merkle root,
-   Reject the proposed Merkle root with a valid zero (`0x000...000`), or
-   Abstain from voting.

Note that 5 attestation providers represent 50%+ of the default set.
If the chosen subset of 5 proposes to confirm an invalid attestation while bit voting, it implies that the majority of the default set is malicious or corrupted, which would require their replacement.

## BitVoting contract deployments in the Block Explorer

-   [On Songbird](https://songbird-explorer.flare.network/address/0xd1Fa33f1b591866dEaB5cF25764Ee95F24B1bE64)
-   [On Flare](https://flare-explorer.flare.network/address/0xd1Fa33f1b591866dEaB5cF25764Ee95F24B1bE64)
-   [On Coston](https://coston-explorer.flare.network/address/0xd1Fa33f1b591866dEaB5cF25764Ee95F24B1bE64)
-   [On Coston2](https://coston2-explorer.flare.network/address/0xd1Fa33f1b591866dEaB5cF25764Ee95F24B1bE64)

Back: [Voting protocol](/specs/scProtocol/voting-protocol.md) | Next: [Merkle tree](/specs/scProtocol/merkle-tree.md) |

[Home](/README.md)
