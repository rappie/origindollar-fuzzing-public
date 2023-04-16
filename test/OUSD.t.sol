// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/token/OUSD.sol";

contract DeployTest is Test {
    address public VAULT = address(0x10000);
    OUSD public ousd = new OUSD();

    function setUp() public {
        ousd.initialize("Origin Dollar", "OUSD", VAULT);
    }

    function testOUSD() public {
        console.log("testOUSD");

        vm.prank(VAULT);
        ousd.mint(address(this), 1000);

        console.log("OUSD Balance", ousd.balanceOf(address(this)));
    }
}
