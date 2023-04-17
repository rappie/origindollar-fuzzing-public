// SPDX-License-Identifier: MIT

import "./IHevm.sol";
import "./EchidnaConfig.sol";

import "../token/OUSD.sol";

contract Dummy {}

contract EchidnaSetup is EchidnaConfig {
    IHevm hevm = IHevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    OUSD ousd = new OUSD();

    constructor() {
        ousd.initialize("Origin Dollar", "OUSD", ADDRESS_VAULT);

        Dummy dummy0 = new Dummy();
        ADDRESS_CONTRACT0 = address(dummy0);
        Dummy dummy1 = new Dummy();
        ADDRESS_CONTRACT1 = address(dummy1);
    }
}
