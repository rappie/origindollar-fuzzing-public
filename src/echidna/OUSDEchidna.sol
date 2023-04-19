// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../token/OUSD.sol";

contract OUSDEchidna is OUSD {
    constructor() OUSD() {}

    function getRebasingCreditsPerToken() public view returns (uint256) {
        return _rebasingCreditsPerToken;
    }
}
