# Attestation configs

## Finality/confirmation

By design, the latest blocks on the main branch are subject to changes, i.e., at some point it might be uncertain which branch should be considered main.
However, blocks at a certain depth are considered confirmed (they will stay on the main branch with a high enough probability).
The data from a confirmed block is safe to be bridged to Songbird blockchain and only data from confirmed blocks is safe to be relayed to Songbird blockchain.

For the stability of the State Connector protocol, all attestation clients must agree at which depth a block is considered to have enough confirmations.
A block at the tip of the chain has depth 1, i.e., it has one confirmation.

The current consensus is:

| `Chain` | `chainId` | `numberOfConfirmations` |
| ------- | --------- | ----------------------- |
| `BTC`   | 0         | 6                       |
| `DOGE`  | 2         | 60                      |
| `XRP`   | 3         | 3                       |

Back: [Attestations](/specs/attestations/attestation.md) |
[Global Configurations](/specs/attestations/configs.md) |
Next: [Attestation Type definition](/specs/attestations/attestation-type-definition.md) |

[Home](/README.md)
