// SPDX-License-Identifier: MIT

contract EchidnaConfig {
    address internal constant ADDRESS_VAULT = address(0x10000);
    address internal constant ADDRESS_OUTSIDER = address(0x20000);

    address internal constant ADDRESS_USER0 = address(0x30000);
    address internal constant ADDRESS_USER1 = address(0x40000);

    // Will be set in EchidnaSetup constructor
    address internal ADDRESS_CONTRACT0;
    address internal ADDRESS_CONTRACT1;

    bool internal TOGGLE_STARTING_BALANCE = true;
    uint256 internal STARTING_BALANCE = 1_000_000e18;

    bool internal TOGGLE_CHANGESUPPLY_LIMIT = true;
    uint256 internal CHANGESUPPLY_DIVISOR = 10;

    function getAccount(uint8 userId) internal view returns (address) {
        userId = userId / 64;
        if (userId == 0) return ADDRESS_USER0;
        if (userId == 1) return ADDRESS_USER1;
        if (userId == 2) return ADDRESS_CONTRACT0;
        if (userId == 3) return ADDRESS_CONTRACT1;
        require(false, "Unknown account ID");
    }
}
