// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, stdJson, console} from "forge-std/Script.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

import "src/KEITestToken.sol";

import "./Base.s.sol";

contract DeployScript is BaseScript {
    using stdJson for string;
    using SafeCast for uint256;

    function run() public {
        vm.startBroadcast(deployer);

        console.log(deployer, deployer.balance);
        console.log(config.owner);

        for (uint256 i; i < config.tokens.length; i++) {
            TokenConfig memory token = config.tokens[i];
            console.log("deploying", token.name, token.symbol, token.decimals);
            console.log(deploy("KEITestToken.sol", abi.encode(token.name, token.symbol, token.decimals.toUint8(), config.owner)));
        }

        vm.stopBroadcast();
    }
}
