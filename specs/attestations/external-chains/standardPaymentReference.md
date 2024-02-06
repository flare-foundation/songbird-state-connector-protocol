# Standard payment reference

In Flare, a standard payment reference is defined as a 32-byte sequence that can be added to a payment transaction, in the same way that a payment reference is attached to a traditional banking transaction.

Blockchains may enable several ways of attaching data as metadata to a transaction.

For each supported blockchain, it is specified how a 32-byte string is included into the metadata to be considered a standard payment reference.

## Bitcoin and Dogecoin

Each unspent transaction output (UTXO) has a pkscript that determines who and how it can be spent.
The `OP_RETURN` [opcode](https://en.bitcoin.it/wiki/Script) in the pkscript makes the UTXO intentionally unspendable.

A transaction is considered to have a `standardPaymentReference` defined if it has exactly one output UTXO with `OP_RETURN` script and the script is of the form `OP_RETURN <reference\>` or `6a<lengthOfReferenceInHex\><reference\>` in hex, where the length of the `reference` is 32 bytes. Then `0x<reference\>` is `standardPaymentReference`.

An example is the Bitcoin transaction with the ID **53bb7420d146c957ed4f41c5175043503b5e953ed5af0387340f8c2c4949c2e1** in block **578,772**
with `standardPaymentReference` **0xbdaf8a8067dae5b453e0e27bd33521c166ddc5dc481ee993006dcea30e6e2e5b**.

## XRPL

On XRPL, the `memoData` field is used to provide the payment reference.

A transaction has a `standardPaymentReference` if it has exactly one [Memo](https://xrpl.org/transaction-common-fields.html#memos-field) and the `memoData` of this `Memo` field is a hex string that represents a byte sequence of exactly 32 bytes.
This 32-byte sequence defines `standardPaymentReference`.

An example is the transaction with the ID **C610A06B5B26A8AF3D24DB7D3D458B8AC46920803B5694FB1FFC0FB7C1857405** in ledger
**81,001,656** with `standardPaymentReference` **0x7274312e312e33322d6275676669782d322d67653135323239372d6469727479**.

Back: [External chains](/specs/attestations/external-chains.md) | [Standard Transaction](/specs/attestations/external-chains/transactions.md) |
Next: [Standard Address](/specs/attestations/external-chains/standardAddress.md)
[Home](/README.md)
