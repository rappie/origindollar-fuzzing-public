// SPDX-License-Identifier: MIT

import "../token/OUSD.sol";

contract OUSDEchidna is OUSD {
    constructor() OUSD() {}

    function getRebasingCreditsPerToken() public view returns (uint256) {
        return _rebasingCreditsPerToken;
    }
}
