// SPDX-License-Identifier: MIT

import "./EchidnaHelper.sol";
import "./Debugger.sol";

contract EchidnaDebug is EchidnaHelper {
    bool debug = true;

    // bool debug = false;

    function debugEchidna() public {
        require(debug);
        assert(false);
    }
}
