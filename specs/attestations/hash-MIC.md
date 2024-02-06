# Attestation hash and Message Integrity Code

## Attestation hash

For each confirmed attestation request, the hash of its full response is computed.
In solidity, the hash of the response is computed in Solidity by the following code:

```solidity
keccak256(abi.encode(response));
```

where the response is a struct of type [Response](/specs/attestations/attestation-type-definition.md#response-format).
Hashes of the confirmed attestation are used to construct the [Merkle tree](/specs/scProtocol/merkle-tree.md) and the Merkle root is used for voting in the attestation round.

## Message Integrity Code

The Message Integrity Code (MIC) is the hash of the expected attestation response with `votingRound` set to zero together with the string `"Flare"`.
A requester provides the MIC to attestation providers, so they can check the verifier's response against the requester's expectations.
Hence, the requestor must know the response in advance.

## Calculation

To calculate both the hash and the MIC from an attestation response for a specific attestation type, the [`AttestationDefinitionStore`](../../libs/ts/AttestationDefinitionStore.ts) utility can be used.

Initialize the class with the path to the extended configuration folder and use the `attestationResponseHash(response, salt?)` function.
For the hash, use an undefined salt, while for the MIC use the salt `"Flare"` and `votingRound` set to `0`.

```Typescript
import { AttestationDefinitionStore } from "../path/to/AttestationDefinitionStore";

const response = ...
const defStore = new AttestationDefinitionStore("path/to/extended/configs/folder");
const hash = defStore.attestationResponseHash(response);
response.votingRound = 0
const mic = defStore.attestationResponseHash(response, "Flare");
```

Back: [Attestation Type definition](/specs/attestations/attestation-type-definition.md) |
[Encoding/decoding](/specs/attestations/encoding-decoding.md) |
Next: [Verifier Server](/specs/attestations/verifier.md) |

[Home](/README.md)
