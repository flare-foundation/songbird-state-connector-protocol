# Branching protocol

The State Connector protocol includes a security mechanism on the validator/observer node level: the ability to fork and halt execution if a validator/observer node disagrees with the Merkle root confirmed by the default set.

In addition to the default set of attestation providers, each node can define its own local set of attestation providers.
Attestation providers in the local set have the same infrastructure as those in the default set and they can be a member of both sets.

Members of the local set have a separate voting mechanism following the same principle as the default set. However, they do not participate in bit voting, and use the default set's bit voting result for assembling the Merkle tree.

For an attestation round to succeed (by the node's criteria), the following conditions must be met:

-   The default set accepts a single Merkle root with more than 50% of the weight.
-   The local set accepts a single Merkle root with more than 50% of the weight.
-   The accepted Merkle roots are identical.

If these conditions are met, the Merkle root is stored on the State Connector contract.

The round is considered unsuccessful if the default set does not agree on a Merkle root.
Then no Merkle root is stored on the State Connector contract and no forks can happen.
If the default set accepts a Merkle root with more than 50% of the weight and at least one of the other conditions is not met, the node forks and halts.

You can find these condition checks in the [source code](https://github.com/flare-foundation/go-songbird/blob/main/avalanchego/coreth/core/state_connector.go).

Ideally, local providers are managed by the same entity that controls the validator node using them, so they can be trusted implicitly.
In addition, the local set must be robust, as the downtime of enough local providers would inevitably lead to a fork and halt.

An unstable local set represents a potential risk for validator nodes.
Namely, attestation type validation requires external queries, which may take time, causing a delay on a node, and potentially leading to unnecessary forks due to delays in data processing.
Nevertheless, under normal non-delayed operation this mechanism can provide a state of blockchain database just before the possibly problematic decision (eg. wrong confirmed attestation).
Such a state can be used to sync the node to the correct fork.

## Branch resolution

When a fork and halt occurs, there are only two possible states:

### The default set has confirmed a Merkle root that matches reality and the local set disagrees

In this case, the operator of the separated validator (such node will get halted) needs to find out why the local attestation providers failed and either fix them or remove them from the local set of the validator.
Once this is fixed, the node simply proceeds with syncing from where it got stuck and quickly fast-forwards to rejoin the default state.
In the event of this kind of fork, dapps depending on information from a separated node just have to wait longer to get their result.

### The default set has confirmed a Merkle root that does not match reality and the local set disagrees

This is a very delicate situation and it should be rare.

The operator of the halted validator node, upon convincing themselves that their branch is the correct one (it matches reality), needs to bring the fork to the attention of the misbehaving attestation providers' operators.
All validators relying on the default state then need to roll back to the last correct state (by syncing from the past snapshot prior to the fork or obtaining the copy of the correct database at fork) and continue from there on the forked branch, which becomes the new default state. This situation will most likely require the change in the validator code, that will have to be distributed globally.

## A note of caution

Due to potential outage risks (and missed rewards) when using the branching mechanism, it is generally recommended to enable the local attestation provider set only on non-validator nodes running in parallel to validator nodes, for network anomaly detection and escalation purposes as describe above.

Back: [Voting protocol](/specs/scProtocol/voting-protocol.md) | [Merkle tree](/specs/scProtocol/merkle-tree.md) |
Next: [Attestations](/specs/attestations/attestation.md) |

[Home](/README.md)
