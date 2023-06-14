// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./EchidnaDebug.sol";
import "./EchidnaTestTransfer.sol";

contract EchidnaTestSupply is EchidnaTestTransfer {
    uint256 prevRebasingCreditsPerToken = type(uint256).max;

    // After a `changeSupply`, the total supply should exactly match the target total supply. (This is needed to ensure successive rebases are correct).
    //
    // testChangeSupply(uint256): failed!💥
    //   Call sequence:
    //       testChangeSupply(1044505275072865171609)
    //
    //   Event sequence:
    //       TotalSupplyUpdatedHighres(1044505275072865171610, 1000000000000000000000000, 957391048054055578595)
    //
    function testChangeSupply(uint256 supply)
        public
        hasKnownIssue
        hasKnownIssueWithinLimits
    {
        hevm.prank(ADDRESS_VAULT);
        ousd.changeSupply(supply);

        assert(ousd.totalSupply() == supply);
    }

    // The total supply may only be greater than the sum of account balances. (The difference will go into future rebases)
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
    function testTotalSupplyVsTotalBalance()
        public
        hasKnownIssue
        hasKnownIssueWithinLimits
    {
        uint256 totalSupply = ousd.totalSupply();
        uint256 totalBalance = getTotalBalance();

        Debugger.log("totalSupply", totalSupply);
        Debugger.log("totalBalance", totalBalance);

        assert(totalSupply >= totalBalance);
    }

    // Non-rebasing supply should not be larger than total supply
    function testNonRebasingSupplyVsTotalSupply() public hasKnownIssue {
        uint256 nonRebasingSupply = ousd.nonRebasingSupply();
        uint256 totalSupply = ousd.totalSupply();

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
    function testRebasingCreditsPerTokenNotIncreased() public hasKnownIssue {
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

    // The rebasing credits per token ratio must greater than zero
    function testRebasingCreditsPerTokenAboveZero() public {
        assert(ousd.rebasingCreditsPerTokenHighres() > 0);
    }
}
