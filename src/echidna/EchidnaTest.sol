// SPDX-License-Identifier: MIT

import "./EchidnaSetup.sol";
import "./EchidnaHelper.sol";
import "./EchidnaDebug.sol";
import "./Debugger.sol";

contract EchidnaTest is EchidnaSetup, EchidnaHelper, EchidnaDebug {
    // The receiving account's balance after a transfer must increase by at least the amount transferred
    // The sending account's balance after a transfer must decrease by no more than amount transferred.
    function testTransferBalance(
        uint8 fromAcc,
        uint8 toAcc,
        uint256 amount
    ) public hasKnownIssue {
        address from = getAccount(fromAcc);
        address to = getAccount(toAcc);

        require(from != to);

        uint256 fromBalBefore = ousd.balanceOf(from);
        uint256 toBalBefore = ousd.balanceOf(to);

        transfer(fromAcc, toAcc, amount);

        uint256 fromBalAfter = ousd.balanceOf(from);
        uint256 toBalAfter = ousd.balanceOf(to);

        Debugger.log("totalSupply", ousd.totalSupply());
        Debugger.log("fromBalBefore", fromBalBefore);
        Debugger.log("fromBalAfter", fromBalAfter);
        Debugger.log("toBalBefore", toBalBefore);
        Debugger.log("toBalAfter", toBalAfter);

        assert(fromBalAfter >= fromBalBefore - amount);
        assert(toBalAfter >= toBalBefore + amount);
    }

    // An account should always be able to successfully transfer an amount within its balance.
    function testTransferWithinBalanceDoesNotRevert(
        uint8 fromAcc,
        uint8 toAcc,
        uint256 amount
    ) public hasKnownIssue {
        address from = getAccount(fromAcc);
        address to = getAccount(toAcc);

        require(amount > 0);
        amount = amount % ousd.balanceOf(from);

        Debugger.log("Total supply", ousd.totalSupply());

        hevm.prank(from);
        try ousd.transfer(to, amount) {
            assert(true);
        } catch {
            assert(false);
        }
    }

    // An account should never be able to successfully transfer an amount greater than their balance.
    function testTransferExceedingBalanceReverts(
        uint8 fromAcc,
        uint8 toAcc,
        uint256 amount
    ) public {
        address from = getAccount(fromAcc);
        address to = getAccount(toAcc);

        amount = ousd.balanceOf(from) + 1 + amount;

        hevm.prank(from);
        try ousd.transfer(to, amount) {
            assert(false);
        } catch {
            assert(true);
        }
    }
}
