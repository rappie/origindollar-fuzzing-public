// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./EchidnaTestMintBurn.sol";
import "./Debugger.sol";

/**
 * @title Mixin for testing approval related functions
 * @author Rappie
 */
contract EchidnaTestApproval is EchidnaTestMintBurn {
    /**
     * @notice Performing `transferFrom` with an amount inside the allowance should not revert
     * @param authorizedAcc The account that is authorized to transfer
     * @param fromAcc The account that is transferring
     * @param toAcc The account that is receiving
     * @param amount The amount to transfer
     */
    function testTransferFromShouldNotRevert(
        uint8 authorizedAcc,
        uint8 fromAcc,
        uint8 toAcc,
        uint256 amount
    ) public {
        address authorized = getAccount(authorizedAcc);
        address from = getAccount(fromAcc);
        address to = getAccount(toAcc);

        require(amount <= ousd.balanceOf(from));
        require(amount <= ousd.allowance(from, authorized));

        hevm.prank(authorized);
        try ousd.transferFrom(from, to, amount) {
            // pass
        } catch {
            assert(false);
        }
    }
}
