// SPDX-License-Identifier: MIT

import "./EchidnaSetup.sol";

contract EchidnaHelper is EchidnaSetup {
    function mint(bool toAcc, uint256 amount) public {
        address to = getAccount(toAcc);
        hevm.prank(ADDRESS_VAULT);
        ousd.mint(to, amount);
    }

    function burn(bool fromAcc, uint256 amount) public {
        address from = getAccount(fromAcc);
        hevm.prank(ADDRESS_VAULT);
        ousd.burn(from, amount);
    }

    function changeSupply(uint256 amount) public {
        hevm.prank(ADDRESS_VAULT);
        ousd.changeSupply(amount);
    }

    function transfer(
        bool fromAcc,
        bool toAcc,
        uint256 amount
    ) public {
        address from = getAccount(fromAcc);
        address to = getAccount(toAcc);
        hevm.prank(from);
        ousd.transfer(to, amount);
    }

    function optIn(bool targetAcc) public {
        address target = getAccount(targetAcc);
        hevm.prank(target);
        ousd.rebaseOptIn();
    }

    function optOut(bool targetAcc) public {
        address target = getAccount(targetAcc);
        hevm.prank(target);
        ousd.rebaseOptOut();
    }
}
