// SPDX-License-Identifier: MIT

import "./EchidnaHelper.sol";
import "./Debugger.sol";

contract EchidnaDebug is EchidnaHelper {
    bool debug = true;

    // bool debug = false;

    function debugOUSDBalance() public view returns (uint256) {
        assert(ousd.balanceOf(ADDRESS_USER0) == 0);
    }

    function debugEchidna() public {
        require(debug);
        assert(false);
    }
}
