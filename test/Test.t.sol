// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.6.0
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {MyGovernor} from "src/Goverance.sol";
import {MyToken} from "src/ERC20Token.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import {IGovernor} from "@openzeppelin/contracts/governance/IGovernor.sol";
import {Box} from "src/Box.sol";

contract GovTest is Test {
    MyGovernor gov;
    MyToken token;
    TimeLock lock;
    Box box;

    address user = makeAddr("user");
    uint256 public constant INITIAL_SUPPLY = 200 ether;
    uint256 public constant MIN_DELAY = 14400;

    address[] proposer;
    address[] executor;

    function setUp() public {
        token = new MyToken(user);

        vm.startPrank(user);
        token.mint(user, INITIAL_SUPPLY);
        token.delegate(user);

        lock = new TimeLock(MIN_DELAY, proposer, executor);
        gov = new MyGovernor(IVotes(token), lock);

        bytes32 proposerRole = lock.PROPOSER_ROLE();
        bytes32 executorRole = lock.EXECUTOR_ROLE();
        bytes32 defaultAdminrole = lock.DEFAULT_ADMIN_ROLE();

        lock.grantRole(proposerRole, address(gov));
        lock.grantRole(executorRole, address(0));
        lock.grantRole(defaultAdminrole, user);
        vm.stopPrank();

        box = new Box(address(lock));
    }

    function test__CheckFlow() public {
        //Arrange
        // unction propose(
        //     address[] memory targets,
        //     uint256[] memory values,
        //     bytes[] memory calldatas,
        //     string memory description
        // ) external returns (uint256 proposalId);
        //      function queue(
        //     address[] memory targets,
        //     uint256[] memory values,
        //     bytes[] memory calldatas,
        //     bytes32 descriptionHash
        // )
        uint256 newNo = 22;
        string memory description = "Because i want to";
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);

        targets[0] = address(box);
        values[0] = 0;
        calldatas[0] = abi.encodeWithSelector(box.setNumber.selector, newNo);

        vm.startPrank(user);
        uint256 proposalId = IGovernor(gov).propose(targets, values, calldatas, description);
        vm.roll(block.number + 14420);
        IGovernor(gov).castVote(proposalId, 1);
        vm.roll(block.number + 50400);
        IGovernor(gov).queue(targets, values, calldatas, keccak256(bytes(description)));
        vm.warp(block.timestamp + MIN_DELAY + 1);
        IGovernor(gov).execute(targets, values, calldatas, keccak256(bytes(description)));
        vm.stopPrank();

        //Act
        //Assert
    }
}
