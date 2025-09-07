// SPDX-License-Identifier: MIT
pragma solidity =0.5.16;

import "forge-std/console.sol";
import "../lib/v2-core/contracts/UniswapV2Pair.sol";

contract PrintInitCodeHash {

    // forge create script/PrintInitCodeHash.s.sol:PrintInitCodeHash --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
    // cast call 0x5FC8d32690cc91D4c39d9d3abcBD16989F875707 "getInitCodeHash()(bytes32)" --rpc-url http://127.0.0.1:8545

    function getInitCodeHash() public pure returns (bytes32) {
        return keccak256(type(UniswapV2Pair).creationCode);
    }
}
