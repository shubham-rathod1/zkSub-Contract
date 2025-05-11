// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import {Logic} from "../src/Logic.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract LogicScript is Script {
    function setUp() public {}

    function run() public {
        // uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        // vm.startBroadcast(deployerKey);
        
        vm.startBroadcast();
        Logic logic = new Logic();

        bytes memory initData = abi.encodeWithSelector(
            Logic.initialize.selector
        );

        ERC1967Proxy proxy = new ERC1967Proxy(address(logic), initData);

        // Log addresses
        console.log("Logic deployed at:", address(logic));
        console.log("Proxy deployed at:", address(proxy));
        console.log("Call Logic functions using proxy address.");

        vm.stopBroadcast();
    }
}
