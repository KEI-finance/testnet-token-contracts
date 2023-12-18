// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import "../script/Deploy.s.sol";

contract DeployTest is Test {

    function test() external {

        DeployScript script = new DeployScript();

        script.setUp();
        script.run();
    }
}
