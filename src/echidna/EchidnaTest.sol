// SPDX-License-Identifier: MIT

import "./EchidnaSetup.sol";
import "./EchidnaHelper.sol";
import "./EchidnaDebug.sol";
import "./Debugger.sol";

contract EchidnaTest is EchidnaSetup, EchidnaHelper, EchidnaDebug {
    // The receiving account's balance after a transfer must increase by at least the amount transferred
    // The sending account's balance after a transfer must decrease by no more than amount transferred.
    //
    // testTransferBalance(uint8,uint8,uint256): failed!💥
    //   Call sequence:
    //     changeSupply(1)
    //     mint(0,2)
    //     testTransferBalance(0,64,1)
    //
    //   Event sequence:
    //       Debug(«totalSupply», 1000000000000000001000002)
    //       Debug(«fromBalBefore», 1)
    //       Debug(«fromBalAfter», 1)
    //       Debug(«toBalBefore», 0)
    //       Debug(«toBalAfter», 0)
    //
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
    //
    // testTransferWithinBalanceDoesNotRevert(uint8,uint8,uint8): failed!💥
    //   Call sequence:
    //       mint(0,1)
    //       changeSupply(3)
    //       optOut(0)
    //       testTransferWithinBalanceDoesNotRevert(0,128,2)
    //       optIn(0)
    //       testTransferWithinBalanceDoesNotRevert(128,0,1)
    //
    //   Event sequence:
    //       error Revert Panic(17): SafeMath over-/under-flows
    //
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

    // A transfer to the same account should not change that account's balance
    function testTransferSelf(uint8 targetAcc, uint256 amount) public {
        address target = getAccount(targetAcc);

        uint256 balanceBefore = ousd.balanceOf(target);
        transfer(targetAcc, targetAcc, amount);
        uint256 balanceAfter = ousd.balanceOf(target);

        assert(balanceBefore == balanceAfter);
    }

    // Transfers to the zero account revert
    function testTransferToZeroAddress(uint8 fromAcc, uint256 amount) public {
        address from = getAccount(fromAcc);

        hevm.prank(from);
        try ousd.transfer(address(0), amount) {
            assert(false);
        } catch {
            assert(true);
        }
    }
}
