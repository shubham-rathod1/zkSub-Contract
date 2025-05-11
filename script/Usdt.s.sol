// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MyUsdt is ERC20, Ownable {
    constructor(address initialOwner)
        ERC20("MyUsdt", "MUSDT")
        Ownable(initialOwner)
    {}

    function decimals() public pure override returns (uint8) {
        return 6;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

contract UsdtScript is Script {

    address Recipient = 0x4605A6219BC5f9138E4a265C1c3e9fDD4FE1E256;

    function setUp() public {}

    function run() public {
        // uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        // vm.startBroadcast(deployerKey);
        
        vm.startBroadcast();
        
        // MyUsdt musdt = new MyUsdt(msg.sender);
        // musdt.mint(Recipient, 1000000 * 1e6);

        IERC20 usdt = IERC20(0xE0DB0D9b205210E0DC83F35a318CB8fA2fe6C9CF);
        usdt.approve(address(0x4bd39388c6b292e8B7628A944Ebdc383e446A47A), 100 * 1e6);
        

        vm.stopBroadcast();
    }
}
