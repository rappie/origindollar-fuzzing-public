// SPDX-License-Identifier: MIT

contract EchidnaConfig {
    address internal constant ADDRESS_VAULT = address(0x10000);
    address internal constant ADDRESS_USER0 = address(0x20000);
    address internal constant ADDRESS_USER1 = address(0x30000);

    function getAccount(bool user0) internal pure returns (address) {
        return user0 ? ADDRESS_USER0 : ADDRESS_USER1;
    }
}
