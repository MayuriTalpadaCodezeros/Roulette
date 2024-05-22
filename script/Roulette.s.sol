// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Roulette} from "../src/Roulette.sol";

contract RouletteScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
        Roulette roulette = new Roulette(5);
        console.log(address(roulette));
    }
}
