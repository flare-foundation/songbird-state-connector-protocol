// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

import "../../../interface/types/BalanceDecreasingTransaction.sol";

interface IBalanceDecreasingTransactionVerification {

   function verifyBalanceDecreasingTransaction(
      BalanceDecreasingTransaction.Proof calldata _proof
   ) external view returns (bool _proved);
}
   