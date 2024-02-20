# External chains

The State Connector enables the use of data from external blockchains.
Currently supported blockchains are: Bitcoin, Dogecoin, XRPL, and Ethereum and their testnets for Coston testnet (Sepolia for Etherum).
Each chain has its own [specifications](/data-sources/data-sources.json).

Each blockchain has its own specifics and nuances; however, there are enough similarities to handle them in a unified way.
For this purpose, Flare set the following standards for interpreting data from these blockchains:

-   [Standardized transactions](/specs/attestations/external-chains/transactions.md)
-   [Standardized address](/specs/attestations/external-chains/standardAddress.md)
-   [Standard payment reference](/specs/attestations/external-chains/standardPaymentReference.md)

It is also important to understand the rules how addresses are formed and which strings can represent an address on external blockchains.
Here are the summarized rules for each supported chain:

-   [BTC](/specs/attestations/external-chains/address-validity/BTC.md)
-   [DOGE](/specs/attestations/external-chains/address-validity/DOGE.md)
-   [XRP](/specs/attestations/external-chains/address-validity/XRP.md)

## Source ID

The source ID of the external chain is the UTF-8 code of its native currency in uppercase (see the list at [data sources](/data-sources/data-sources.json)) and padded with zeros on the right to a `0x`-prefixed 32-byte, lowercase string.
For example, ID of Bitcoin is `0x4254430000000000000000000000000000000000000000000000000000000000`.
Here string `BTC` is first converted to a hex byte sequence `0x425443` and then
padded with zero bytes to 32 bytes.
Functions for such encoding and decoding (`encodeAttestationName` and `decodeAttestationName`) are available in the [utils library](/libs/ts/utils.ts).

## Timestamp

Each block has an assigned timestamp that is supposed to indicate the time at which the block was minted.
It is crucial for State Connector protocol for the timestamps to be monotonically increasing.
All timestamps used by the State Connector should be given in UNIX time - seconds elapsed since 00:00:00 UTC on January first 1970.

### Bitcoin and Dogecoin

Each block has two timestamps: `time` and `mediantime`.
`Time` is set by the miner of the block and it should be the exact time in which the block was mined.
However, the miner can influence the `time` of a block in such a way that it is lower than the `time` of the previous block without breaching the consensus rules.
The `mediantime` is the median of the past 11 block `time`s.

Block `time` has to be greater than block `mediantime` by the consensus rule.
Following from the rule, `mediantime` is strictly increasing.

In normal conditions, `mediantime` of a block is the block time of the sixth block prior.
On Bitcoin, this is on average around an hour.
On Dogecoin, this is on average around six minutes.

### XRPL

On XRPL, the time of a ledger (block) is given by [close time](https://xrpl.org/ledger-close-times.html), which is monotonically increasing.
On XRPL, time is given as seconds from 00:00:00 UTC on January first 2000.
The UNIX timestamp is recovered by adding 946,684,800 seconds.

In ledger, the timestamp is found under the filed `close_time`.
In transaction, the timestamps is found under the field `date`, which is equal to the `close_time` of the ledger that includes the transaction.

### Ethereum

On EVM chains, block timestamp is unix and monotonically increasing.

[Home](/README.md)
