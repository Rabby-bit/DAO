// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Box is Ownable {
    uint256 private s_number;

    constructor(address _initialOwner) Ownable(_initialOwner) {}

    function setNumber(uint256 newNumber) public {
        s_number = newNumber;
    }

    function getCurrentNumber() public view returns (uint256) {
        return s_number;
    }
}
