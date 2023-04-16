// SPDX-License-Identifier: MIT

import "./IHevm.sol";
import "./EchidnaConfig.sol";

contract EchidnaSetup is EchidnaConfig {
    IHevm hevm = IHevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
}
