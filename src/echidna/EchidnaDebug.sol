// SPDX-License-Identifier: MIT

import "./EchidnaHelper.sol";
import "./Debugger.sol";

import "../token/OUSD.sol";

contract EchidnaDebug is EchidnaHelper {
    function debugOUSD() public view returns (uint256) {
        // assert(ousd.balanceOf(ADDRESS_USER0) == 1000);
        // assert(ousd.rebaseState(ADDRESS_USER0) != OUSD.RebaseOptions.OptIn);
    }
}
