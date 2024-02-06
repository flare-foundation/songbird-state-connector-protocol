# Transaction summaries

When validating certain attestation types we use specific transaction summaries:

-   Payment summaries.
-   Balance-decreasing summaries.

The summaries provide a generalized view of transactions.
The calculation of the summaries depends on the type of blockchain the transaction is made on.
In general, there is a differentiation between UTXO-based and account-based blockchains.

## UTXO based block chains

On UTXO blockchains, a transaction is defined by a set of (transaction) inputs and a set of (transaction) outputs.
Each output has a value and a locking script (`scriptPubKey`), which specifies how it can be spent in the next transaction.
Until a transaction output is used as input of another transaction, it is called **unspent transaction output (UTXO)**.
Usually, unlocking the script requires owning the correct private key that signs the transaction that is spending the UTXO.
Inputs are references to outputs of previous transactions (by transaction ID and an output index) together with the correct unlocking scripts (`scriptSig`).
The value of an input is the value of the referenced output.

Each block contains one special _coinbase_ transaction, which does not have inputs and generates output with block rewards.
In a non-coinbase transaction, the sum of values of inputs has to be smaller than the sum of values of the outputs.
The difference is called the _fee_ and is included in the block reward.

The UTXO-based blockchains considered in this document are Bitcoin and Dogecoin.

The value on UTXO blockchains is stored in UTXOs
A unique address is assigned to a standard locking script and the locking script can be recovered from an address.
In some sense, an address can be considered as an account whose balance is the sum of values of all UTXOs that have a locking script corresponding to the address.

## Account-based blockchains

On account-based blockchains, an account can hold a native currency.
Each transaction can decrease the balance of some accounts and increase the balance of other accounts.
The total sum of the changes is negative and is paid as a fee.
All accounts whose balance has been decreased must give consent in some way or another.
Usually the consent is given by a signature in the current or some prior transaction (e.g., prior approval of a check amount that can be withdrawn in the future).

## Transaction success status

Each transaction has an assigned success status that describes the transaction's success.

Once a transaction is submitted onto a blockchain, it can be included in a block or not.
The block can get confirmed or not.
If the transaction is not included in a confirmed block, it is not considered confirmed.
Each transaction must be correctly formed and specified.
In some cases, a transaction is not successful even if it is included in a confirmed block.
For example, the transaction with txHash: `FBB6DEF1573C2FDE836DE872FAAE181C93B9E0D9C9260FB06EEC4427F0220BB6` on XRPL is included in a confirmed block, however, it failed: It did not make its intended change.

Failure of a transaction that gets included in a confirmed block can, on different blockchains, happen for different reasons.
In general, failure can be attributed to the sender or to the receiver.
For example, on XRPL a receiver can block incoming payments.
Even if a sender submits a well formed payment to the receiver,
the transaction fails due to blockage.
However, it will still be confirmed in a block as a failed transaction, as a proof of a legitimate payment attempt.
The following table lists possible transaction success statuses.

| status             | code |
| ------------------ | ---- |
| `SUCCESS`          | 0    |
| `SENDER_FAILURE`   | 1    |
| `RECEIVER_FAILURE` | 2    |

The assignment of a transaction success status depends on the specific blockchain.

### Bitcoin and Dogecoin

It is not possible to include an unsuccessful transaction in a Bitcoin or Dogecoin block.
Hence, if a transaction is included on a confirmed block, its status is "SUCCESS."

### XRPL

On XRPL, some transactions that failed (based on the reason for failure) can be included in a confirmed block.
The [success of the transaction](https://xrpl.org/look-up-transaction-results.html#case-included-in-a-validated-ledger) included in a confirmed block is described by the `TransactionResult` field.
A successful transaction is labeled by `tesSUCCESS`.
If a transaction fails but is included in a block, the [`tec`-class](https://xrpl.org/tec-codes.html) code is used to indicate the reason for the failure.

The following codes indicate a failure that was the receiver's fault:

-   `tecDST_TAG_NEEDED`: A destination tag is required by the target address, but is not provided. **IMPORTANT**: tagging this as the receiver's fault means that attestation types that use the transaction status as described here do not (fully) support transactions that require a destination tag.
-   `tecNO_DST`: This failure is considered to be the receiver's fault if the specified address does not exist or is unfunded.
-   `tecNO_DST_INSUF_XRP`: This failure is considered to be the receiver's fault if the specified address does not exist or is unfunded.
-   `tecNO_PERMISSION`: The source address does not have permission to transfer the target address. **IMPORTANT**: tagging this as the receiver's fault means that attestation types that use transaction statuses as described here do not (fully) support transactions to the accounts that require "DepositAuth".

The rest of the tags indicate the sender's fault.

## Payment summary

A payment summary is used to gather all relevant data about a transaction that represents a payment of some sort.
Our main interest with payment is related to payments from one account (address) to another.
Transactions on a UTXO blockchain can collect funds from many accounts (addresses) and wire them to many other addresses.
On UTXO chains (BTC, DOGE), the payment summary is calculated with respect to specified input and output indices, which point to the addresses of interest.

On XRPL, there are several types of transactions.
The payment summary is fully calculated only for transactions of type Payment.

A payment summary contains the fields as stated in the table below.
The interpretation of some fields is chain dependent.
Descriptions of these fields are left empty and are later explained for each blockchain.

For a given transaction, a payment summary can be calculated only of transaction that are considered to be payment.
When implemented, the function that calculates the payment summary tries to calculate it.
If it is successful, it returns a success status and the summary itself.
If not, it returns an error status.

| Field                      | Description                                                                              |
| -------------------------- | ---------------------------------------------------------------------------------------- |
| `transactionId`            |                                                                                          |
| `transactionStatus`        | The [success status](#transaction-success-status) of the transaction.                    |
| `standardPaymentReference` | The [standard payment reference](./standardPaymentReference.md) of the transaction.      |
| `oneToOne`                 | Indicates whether only one sender and only one receiver are involved in the transaction. |
| `sourceAddress`            |                                                                                          |
| `spentAmount`              |                                                                                          |
| `intendedSourceAmount`     |                                                                                          |
| `receivingAddress`         |                                                                                          |
| `intendedReceivingAddress` |                                                                                          |
| `receivedAmount`           |                                                                                          |
| `intendedReceivingAmount`  |                                                                                          |

[Standard address hashes](/specs/attestations/external-chains/standardAddress.md#standard-address-hash) can be calculated from the addresses.
If the `transactionStatus` is not `SUCCESS`, the `receivingAddress` is an empty string.
In this case, the standard address hash of the receivingAddress is the zero 32-bytes string.

The following describes some fields in detail for each supported chain.

### Bitcoin and Dogecoin

The payment summary is calculated for the given indices of a transaction input and a transaction output.
If the indicated input or output does not exist, no summary is made.
Both the indicated input and output must have an address, otherwise no summary is made.
(For example, an output with a locking script that starts with `OP_RETURN` does not have an address.)
In particular, the summary is not made for coinbase transactions.

For transactions on Bitcoin, all the relevant information about the transaction is obtained using the `getrawtransaction` endpoint with verbosity 2 (available from Bitcoin node with version above 25.0) and `getblock`.

Since Dogecoin node does not support `getrawtransaction` with verbosity 2, some other method needs to be employed to get the data about the input transactions.

| Field                      | Description                                                                                                                                                                                             |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `transactionId`            | The transaction ID found in the field "txid`. For segwit transactions, this is not the same as "hash".                                                                                                  |
| `oneToOne`                 | This is true if and only if only `sourceAddress` appears on inputs: whereas, outputs may consist only of UTXOs wiring to `receivingAddress`, `sourceAddress` (returning the change) or are `OP_RETURN`. |
| `sourceAddress`            | The address of the specified input.                                                                                                                                                                     |
| `spentAmount`              | The sum of values of all inputs with `sourceAddress` minus the sum of values of all outputs with `sourceAddress`.                                                                                       |
| `intendedSourceAmount`     | Always the same as `spentAmount`.                                                                                                                                                                       |
| `receivingAddress`         | The address of the specified output.                                                                                                                                                                    |
| `intendedReceivingAddress` | Always the same as `intendedSourceAddress`.                                                                                                                                                             |
| `receivedAmount`           | The sum of values of all outputs with the `receivingAddress` minus the sum of values of all inputs with `receivingAddress`.                                                                             |
| `intendedReceivingAmount`  | Always the same as `receivedAmount`.                                                                                                                                                                    |

### XRPL

Only transactions of type `Payment` are considered.
If a transaction is of a different type, no summary is made.
In such transactions, there is exactly one sender and at most one receiver.
If a transaction is not successful, there is no receiver.
If it is successful, there is exactly one receiver.

All the information is obtained using method: [`tx`](https://xrpl.org/tx.html).
The actual changes are that the transaction made on the ledger can be found in `meta` (if the transaction is found in a ledger using method `ledger`, the field `meta` is replaced by `metaData`) under `AffectedNodes` field, where `ModifiedNodes` field holds the information about account balance changes (among other things).
The changes can be seen from differences between `FinalFields` and `PreviousFields` subfields.

| Field                      | Description                                                                                                                                                                                     |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `transactionId`            | Hash of the transaction found in the field `hash`.                                                                                                                                              |
| `oneToOne`                 | Always `true`.                                                                                                                                                                                  |
| `sourceAddress`            | The address whose balance has been lowered by the transaction.                                                                                                                                  |
| `spentAmount`              | The amount for which the balance of the `sourceAddress` has been lowered.                                                                                                                       |
| `intendedSourceAmount`     | Calculated as `Amount + Fee`. Same as `spentAmount` if the `transactionStatus` is `SUCCESS`.                                                                                                    |
| `receivingAddress`         | The address whose balance has been increased by the transaction. An empty string if the transaction is not successful.                                                                          |
| `intendedReceivingAddress` | The address whose balance increases if the transaction is successful. Found under `Destination`.                                                                                                |
| `receivedAmount`           | The amount for which the balance of the `receivingAddress` has been increased. Can be zero if the transaction is not successful.                                                                |
| `intendedReceivingAmount`  | The amount for which the balance of `intendedReceivingAddress` increases if the transaction is successful. Found under `Amount`. Same as `spentAmount` if the `transactionStatus` is `SUCCESS`. |

## Balance-decreasing summary

A balance-decreasing summary analyses a transaction that has decreased or could possibly decrease the balance of an account.

A balance-decreasing summary is calculated for a given transaction and source address indicator (`sourceAddressIndicator`).
The summary contains the fields as stated in the table below.
The interpretation of some fields is chain dependent.
Descriptions of these fields are left empty and are later explained for each specific blockchain.

For a given transaction and an address indicator, the balance-decreasing summary can only be calculate if the transaction is considered to be balance-decreasing for the indicated address
When implemented, the function that calculates the balance-decreasing summary
tries to calculate it.
If it is successful, it returns a success status and the summary itself.
If not, it returns an error status.

| Field                      | Description                                                                         |
| -------------------------- | ----------------------------------------------------------------------------------- |
| `transactionId`            |                                                                                     |
| `transactionStatus`        | The [success status](#transaction-success-status) of the transaction.               |
| `sourceAddress`            |                                                                                     |
| `spentAmount`              |                                                                                     |
| `standardPaymentReference` | The [standard payment reference](./standardPaymentReference.md) of the transaction. |

The following are detailed descriptions of fields for each supported chain.

### Bitcoin and Dogecoin

For Bitcoin and Dogecoin, `sourceAddressIndicator` is the index of a transaction input (in hex zero padded on the left to 0x prefixed 32 bytes).
If the input with the given index does not exist or the indicated input does not have an address, no summary is made.
In particular, no summary is made for coinbase transactions.

| Field           | Description                                                                                                                        |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| `transactionId` | The transaction ID found in the field `txidz`. For segwit transactions, this is not the same as _hash_.                            |
| `sourceAddress` | Address of the indicated input.                                                                                                    |
| `spentAmount`   | The sum of values of all inputs with `sourceAddress` minus the sum of values of all outputs with `sourceAddress`. Can be negative. |

### XRPL

For XRPL, `sourceAddressIndicator` is [standardAddressHash](/specs/attestations/external-chains/standardAddress.md#standard-address-hash) of the indicated address.
If the `sourceAddressIndicator` does not match any of the addresses who signed the transaction or whose balance was decreased by the transaction, the summary is not made.

| Field           |                                                                                                                                                         |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `transactionId` | Hash of the transaction found in the field `hash`.                                                                                                      |
| `sourceAddress` | Address whose [standardAddressHash](/specs/attestations/external-chains/standardAddress.md#standard-address-hash) matches the `sourceAddressIndicator`. |
| `spentAmount`   | The amount for which the balance of the `sourceAddress` has lowered. Can be negative.                                                                   |

Back: [External chains](/specs/attestations/external-chains.md) |
Next: [Standard Payment Reference](/specs/attestations/external-chains/standardPaymentReference.md)
[Home](/README.md)
