# Payment

## Description

A relay of a transaction on an external chain that is considered a payment in a native currency.
Various blockchains support different types of native payments. For each blockchain, it is specified how a payment
transaction should be formed to be provable by this attestation type.
The provable payments emulate traditional banking payments from entity A to entity B in native currency with an optional payment reference.

**Supported sources:** BTC, DOGE, XRP, (testBTC, testDOGE, testXRP)

## Request body

| Field           | Solidity type | Description                                                                                                            |
| --------------- | ------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `transactionId` | `bytes32`     | ID of the payment transaction.                                                                                         |
| `inUtxo`        | `uint256`     | For UTXO chains, this is the index of the transaction input with source address. Always 0 for the non-utxo chains.     |
| `utxo`          | `uint256`     | For UTXO chains, this is the index of the transaction output with receiving address. Always 0 for the non-utxo chains. |

## Response body

| Field                          | Solidity type | Description                                                                                                                                                                                     |
| ------------------------------ | ------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `blockNumber`                  | `uint64`      | Number of the block in which the transaction is included.                                                                                                                                       |
| `blockTimestamp`               | `uint64`      | The timestamp of the block in which the transaction is included.                                                                                                                                |
| `sourceAddressHash`            | `bytes32`     | Standard address hash of the source address.                                                                                                                                                    |
| `receivingAddressHash`         | `bytes32`     | Standard address hash of the receiving address. The zero 32-byte string if there is no receivingAddress (if `status` is not success).                                                           |
| `intendedReceivingAddressHash` | `bytes32`     | Standard address hash of the intended receiving address. Relevant if the transaction is unsuccessful.                                                                                           |
| `spentAmount`                  | `int256`      | Amount in minimal units spent by the source address.                                                                                                                                            |
| `intendedSpentAmount`          | `int256`      | Amount in minimal units to be spent by the source address. Relevant if the transaction status is unsuccessful.                                                                                  |
| `receivedAmount`               | `int256`      | Amount in minimal units received by the receiving address.                                                                                                                                      |
| `intendedReceivedAmount`       | `int256`      | Amount in minimal units intended to be received by the receiving address. Relevant if the transaction is unsuccessful.                                                                          |
| `standardPaymentReference`     | `bytes32`     | [Standard payment reference](/specs/attestations/external-chains/standardPaymentReference.md) of the transaction.                                                                               |
| `oneToOne`                     | `bool`        | Indicator whether only one source and one receiver are involved in the transaction.                                                                                                             |
| `status`                       | `uint8`       | [Succes status](/specs/attestations/external-chains/transactions.md#transaction-success-status) of the transaction: 0 - success, 1 - failed by sender's fault,x 2 - failed by receiver's fault. |

## Verification

The transaction with `transactionId` is fetched from the API of the blockchain node or relevant indexer.
If the transaction cannot be fetched or the transaction is in a block that does not have a sufficient [number of confirmations](/specs/attestations/configs.md#finalityconfirmation), the attestation request is rejected.
Once the transaction is received, the [payment summary](/specs/attestations/external-chains/transactions.md#payment-summary) is computed according to the rules for the source chain.
If the summary is successfully calculated, the response is assembled from the summary.
`blockNumber` and `blockTimestamp` are retrieved from the block if they are not included in the transaction data.
For Bitcoin and Dogecoin, `blockTimestamp` is mediantime of the block.
For XRPL, `blockTimestamp` is close time of the ledger converted to UNIX time.
If the summary is not successfully calculated, the attestation request is rejected.

## Lowest Used Timestamp

For `lowestUsedTimestamp`, `blockTimestamp` is used.

Back: [Currently supported types](/specs/attestations/active-types.md)|

[Home](/README.md)
