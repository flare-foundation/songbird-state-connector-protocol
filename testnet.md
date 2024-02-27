# Coston testnet specifics

State Connector on Coston is configured differently than on Songbird to facilitate easier, more accessible and cheaper operation.

## Supported Chains

Instead of mainnet Bitcoin, Dogecoin, XRPL, Ethereum and Flare, testnets are supported on Coston.

| `sourceID` | `chain`          |
| ---------- | ---------------- |
| testBTC    | Bitcoin testnet  |
| testDOGE   | Dogecoin testnet |
| testXRP    | XRPL testnet     |
| testETH    | Sepolina         |
| testFLR    | Coton2           |

## Number of Confirmations

Some attestation types use a fixed number of confirmations at which a block is considered to be confirmed.
On Coston the numbers are reduced to lower the waiting time

| `sourceID` | `numberOfConfirmations` |
| ---------- | ----------------------- |
| testBTC    | 6                       |
| testDOGE   | 6                       |
| testXRP    | 1                       |
