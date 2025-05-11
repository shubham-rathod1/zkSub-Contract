// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {Logic} from "../src/Logic.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
contract LogicTest is Test {
    Logic logic;
    Logic manager;
    ERC1967Proxy proxy;
    address owner = vm.addr(1);
    address provider_1 = vm.addr(2);
    address provider_2 = vm.addr(3);
    address user_1 = vm.addr(4);
    address user_2 = vm.addr(5);
    ERC20Mock usdcToken;
    address usdc;

    bytes32 planId;
    bytes32 planId_1;
    bytes32 zkKey;
    bytes32 zkKey_1;

    function setUp() public {
        vm.startPrank(owner);
        logic = new Logic();
        bytes memory initData = abi.encodeWithSelector(
            Logic.initialize.selector
        );
        proxy = new ERC1967Proxy(address(logic), initData);
        manager = Logic(address(proxy));
        vm.stopPrank();
        // Deploy mock USDC token
        usdcToken = new ERC20Mock();
        usdc = address(usdcToken);
        // Mint tokens to user_1
        usdcToken.mint(user_1, 2 ether);
        // Generate dummy identifiers
        planId = keccak256("gold_plan");
        planId_1 = keccak256("silver_plan");
        zkKey = keccak256("user_secret");
        zkKey_1 = keccak256("user_secret_1");
    }

    function testCreatePlan() public {
        vm.prank(provider_1);
        manager.createPlan(planId, provider_1, usdc, 1 ether, 500, false, 2);
        assertEq(manager.getProviderPlan(provider_1)[0], planId);
    }

    function testCannotDoubleCreatePlan() public {
        vm.prank(provider_1);
        manager.createPlan(planId, provider_1, usdc, 1 ether, 500, false, 2);
        vm.expectRevert("Plan already exists");
        vm.prank(provider_1);
        manager.createPlan(planId, provider_1, usdc, 1 ether, 500, false, 2);
        assertEq(manager.getProviderPlan(provider_1)[0], planId);
    }

    function testDeactivatePlan() public {
        vm.startPrank(provider_1);
        manager.createPlan(planId, provider_1, usdc, 1 ether, 500, false, 2);
        manager.deactivatePlan(planId);
        (, , , , , , bool isActive, ) = manager.plans(planId);
        // assertEq(isActive, false);
        assertFalse(isActive);
        vm.stopPrank();
    }

    function testsubscribeSuccess() public {
        vm.prank(provider_1);
        manager.createPlan(planId, provider_1, usdc, 1 ether, 500, false, 2);
        vm.prank(user_1);
        usdcToken.approve(address(manager), 1 ether);
        vm.prank(user_1);
        manager.subscribe(planId, zkKey);
        assertGt(manager.getExpiry(zkKey), block.timestamp);
    }

    function testPauseContract() public {
        vm.prank(owner);
        manager.pause();

        vm.prank(provider_1);
        manager.createPlan(planId, provider_1, usdc, 1 ether, 500, false, 2);

        vm.prank(user_1);
        vm.expectRevert("Contract is paused");
        manager.subscribe(planId, zkKey);
    }
    function testCannotSubscribeToInactivePlan() public {
        vm.prank(provider_1);
        manager.createPlan(planId, provider_1, usdc, 1 ether, 500, false, 2);

        vm.prank(provider_1);
        manager.deactivatePlan(planId);

        vm.prank(user_1);
        vm.expectRevert("Plan is not active");
        manager.subscribe(planId, zkKey);
    }
}
