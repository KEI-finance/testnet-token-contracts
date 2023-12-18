// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2, stdJson} from "forge-std/Script.sol";

abstract contract BaseScript is Script {
    using stdJson for string;

    struct TokenConfig {
        uint256 decimals;
        string name;
        string symbol;
    }

    struct DeployConfig {
        address owner;
        bytes32 salt;
        TokenConfig[] tokens;
    }

    address public deployer;
    DeployConfig public config;
    mapping(string => address) internal deployments;

    function setUp() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        deployer = vm.rememberKey(privateKey);
        loadConfig();
    }

    function getAddress(string memory name) internal view returns (address) {
        return getAddress(name, "");
    }

    function getAddress(string memory name, bytes memory args) internal view returns (address) {
        bytes32 hash = hashInitCode(vm.getCode(name), args);
        return computeCreate2Address(config.salt, hash);
    }

    function deploy(string memory name) internal returns (address addr) {
        return deploy(name, "", true);
    }

    function deploy(string memory name, bool deployIfMissing) internal returns (address addr) {
        return deploy(name, "", deployIfMissing);
    }

    function deploy(string memory name, bytes memory args) internal returns (address addr) {
        return deploy(name, args, true);
    }

    function deploy(string memory name, bytes memory args, bool deployIfMissing) internal returns (address addr) {
        addr = getAddress(name, args);
        deployments[name] = addr;

        if (addr.code.length == 0) {
            require(deployIfMissing, string.concat("MISSING_CONTRACT_", name));

            bytes memory bytecode = abi.encodePacked(vm.getCode(name), args);
            bytes32 salt = config.salt;

            assembly {
                addr := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
                if iszero(extcodesize(addr)) { revert(0, 0) }
            }
        }
    }

    function loadConfig() internal {
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/config.json");
        string memory json = vm.readFile(path);

        Chain memory chain = getChain(block.chainid);
        string memory key = string.concat(".", chain.chainAlias);

        DeployConfig memory _config = abi.decode(json.parseRaw(key), (DeployConfig));

        config.owner = _config.owner;
        config.salt = _config.salt;
        for (uint256 i; i < _config.tokens.length; i++) {
            config.tokens.push(_config.tokens[i]);
        }
    }
}
