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
    ) public {
        address from = getAccount(fromAcc);
        address to = getAccount(toAcc);

        require(from != to);

        uint256 fromBalBefore = ousd.balanceOf(from);
        uint256 toBalBefore = ousd.balanceOf(to);

        transfer(fromAcc, toAcc, amount);

        uint256 fromBalAfter = ousd.balanceOf(from);
        uint256 toBalAfter = ousd.balanceOf(to);

        Debugger.log("fromBalBefore", fromBalBefore);
        Debugger.log("fromBalAfter", fromBalAfter);
        Debugger.log("toBalBefore", toBalBefore);
        Debugger.log("toBalAfter", toBalAfter);

        assert(fromBalAfter >= fromBalBefore - amount);
        assert(toBalAfter >= toBalBefore + amount);
    }
}
