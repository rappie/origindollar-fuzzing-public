// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./EchidnaSetup.sol";
import "./EchidnaHelper.sol";
import "./EchidnaDebug.sol";
import "./Debugger.sol";

contract EchidnaTest is EchidnaSetup, EchidnaHelper, EchidnaDebug {
    uint256 prevRebasingCreditsPerToken = type(uint256).max;

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

    // After a `changeSupply`, the total supply should exactly match the target total supply. (This is needed to ensure successive rebases are correct).
    //
    // testChangeSupply(uint256): failed!💥
    //   Call sequence:
    //       testChangeSupply(1044505275072865171609)
    //
    //   Event sequence:
    //       TotalSupplyUpdatedHighres(1044505275072865171610, 1000000000000000000000000, 957391048054055578595)
    //
    function testChangeSupply(uint256 supply) public hasKnownIssue {
        hevm.prank(ADDRESS_VAULT);
        ousd.changeSupply(supply);

        assert(ousd.totalSupply() == supply);
    }

    // The total supply may be greater than the sum of account balances. (The difference will go into future rebases)
    //
    // testTotalSupplyVsTotalBalance(): failed!💥
    //   Call sequence:
    //     mint(0,1)
    //     changeSupply(1)
    //     optOut(64)
    //     transfer(0,64,1)
    //     testTotalSupplyVsTotalBalance()
    //
    //   Event sequence:
    //     Debug(«totalSupply», 1000000000000000001000001)
    //     Debug(«totalBalance», 1000000000000000001000002)
    //
    function testTotalSupplyVsTotalBalance() public hasKnownIssue {
        uint256 totalSupply = ousd.totalSupply();
        uint256 totalBalance = getTotalBalance();

        Debugger.log("totalSupply", totalSupply);
        Debugger.log("totalBalance", totalBalance);

        assert(totalSupply >= totalBalance);
    }

    // Non-rebasing supply should not be larger than total supply
    function testNonRebasingSupplyVsTotalSupply() public {
        uint256 nonRebasingSupply = ousd.nonRebasingSupply();
        uint256 totalSupply = ousd.totalSupply();

        Debugger.log("nonRebasingSupply", nonRebasingSupply);
        Debugger.log("totalSupply", totalSupply);

        assert(nonRebasingSupply <= totalSupply);
    }

    // Global `rebasingCreditsPerToken` should never increase
    //
    // 💥 Known to break when manually calling `changeSupply`. This can be reproduced by toggling `TOGGLE_CHANGESUPPLY_LIMIT`.
    //
    // Call sequence:
    //   testRebasingCreditsPerTokenNotIncreased()
    //   changeSupply(1)
    //   testRebasingCreditsPerTokenNotIncreased()
    //
    function testRebasingCreditsPerTokenNotIncreased() public {
        uint256 curRebasingCreditsPerToken = ousd
            .rebasingCreditsPerTokenHighres();

        Debugger.log(
            "prevRebasingCreditsPerToken",
            prevRebasingCreditsPerToken
        );
        Debugger.log("curRebasingCreditsPerToken", curRebasingCreditsPerToken);

        assert(curRebasingCreditsPerToken <= prevRebasingCreditsPerToken);

        prevRebasingCreditsPerToken = curRebasingCreditsPerToken;
    }

    // Account balance should not increase when opting in. (Ok to lose rounding funds doing this)
    function testOptInBalance(uint8 targetAcc) public {
        address target = getAccount(targetAcc);

        uint256 balanceBefore = ousd.balanceOf(target);
        optIn(targetAcc);
        uint256 balanceAfter = ousd.balanceOf(target);

        Debugger.log("balanceBefore", balanceBefore);
        Debugger.log("balanceAfter", balanceAfter);

        assert(balanceAfter <= balanceBefore);
    }

    // Account balance should remain the same after opting out
    function testOptOutBalance(uint8 targetAcc) public {
        address target = getAccount(targetAcc);

        uint256 balanceBefore = ousd.balanceOf(target);
        optOut(targetAcc);
        uint256 balanceAfter = ousd.balanceOf(target);

        Debugger.log("balanceBefore", balanceBefore);
        Debugger.log("balanceAfter", balanceAfter);

        assert(balanceAfter == balanceBefore);
    }

    // After opting in, total supply should remain the same
    function testOptInTotalSupply(uint8 targetAcc) public {
        uint256 totalSupplyBefore = ousd.totalSupply();
        optIn(targetAcc);
        uint256 totalSupplyAfter = ousd.totalSupply();

        Debugger.log("totalSupplyBefore", totalSupplyBefore);
        Debugger.log("totalSupplyAfter", totalSupplyAfter);

        assert(totalSupplyAfter == totalSupplyBefore);
    }

    // After opting out, total supply should remain the same
    function testOptOutTotalSupply(uint8 targetAcc) public {
        uint256 totalSupplyBefore = ousd.totalSupply();
        optOut(targetAcc);
        uint256 totalSupplyAfter = ousd.totalSupply();

        Debugger.log("totalSupplyBefore", totalSupplyBefore);
        Debugger.log("totalSupplyAfter", totalSupplyAfter);

        assert(totalSupplyAfter == totalSupplyBefore);
    }

    // Account balance should remain the same when a smart contract auto converts
    function testAutoConvertBalance(uint8 targetAcc) public {
        address target = getAccount(targetAcc);

        uint256 balanceBefore = ousd.balanceOf(target);
        ousd._isNonRebasingAccountEchidna(target);
        uint256 balanceAfter = ousd.balanceOf(target);

        Debugger.log("balanceBefore", balanceBefore);
        Debugger.log("balanceAfter", balanceAfter);

        assert(balanceAfter == balanceBefore);
    }

    // The `balanceOf` function should never revert
    function testBalanceOfShouldNotRevert(uint8 targetAcc) public {
        address target = getAccount(targetAcc);

        try ousd.balanceOf(target) {
            assert(true);
        } catch {
            assert(false);
        }
    }

    // The rebasing credits per token ratio must greater than zero
    function testRebasingCreditsPerTokenAboveZero() public {
        assert(ousd.rebasingCreditsPerTokenHighres() > 0);
    }

    // Minting 0 tokens should not affect account balance
    function testMintZeroBalance(uint8 targetAcc) public {
        address target = getAccount(targetAcc);

        uint256 balanceBefore = ousd.balanceOf(target);
        mint(targetAcc, 0);
        uint256 balanceAfter = ousd.balanceOf(target);

        Debugger.log("balanceBefore", balanceBefore);
        Debugger.log("balanceAfter", balanceAfter);

        assert(balanceAfter == balanceBefore);
    }

    // Burning 0 tokens should not affect account balance
    function testBurnZeroBalance(uint8 targetAcc) public {
        address target = getAccount(targetAcc);

        uint256 balanceBefore = ousd.balanceOf(target);
        burn(targetAcc, 0);
        uint256 balanceAfter = ousd.balanceOf(target);

        Debugger.log("balanceBefore", balanceBefore);
        Debugger.log("balanceAfter", balanceAfter);

        assert(balanceAfter == balanceBefore);
    }

    // Minting tokens should always increase the account balance by at least amount
    //
    // testMintBalance(uint8,uint256): failed!💥
    //   Call sequence:
    //       changeSupply(1)
    //       testMintBalance(0,1)
    //
    //   Event sequence:
    //       Debug(«balanceBefore», 0)
    //       Debug(«balanceAfter», 0)
    //
    function testMintBalance(uint8 targetAcc, uint256 amount)
        public
        hasKnownIssue
    {
        address target = getAccount(targetAcc);

        uint256 balanceBefore = ousd.balanceOf(target);
        uint256 amountMinted = mint(targetAcc, amount);
        uint256 balanceAfter = ousd.balanceOf(target);

        Debugger.log("amountMinted", amountMinted);
        Debugger.log("balanceBefore", balanceBefore);
        Debugger.log("balanceAfter", balanceAfter);

        assert(balanceAfter >= balanceBefore + amountMinted);
    }
}
