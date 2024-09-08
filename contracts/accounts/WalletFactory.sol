// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// import "hardhat/console.sol";

import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {Wallet} from "./Wallet.sol";

abstract contract WalletFactory {
    Wallet public accountImplementation;

    mapping(address => uint256) public salts;

    // constructor() {}

    function _setImplementation() internal {
        accountImplementation = new Wallet();
    }

    /* Create Account */

    function createAccount(address owner) public virtual returns (Wallet ret) {
        address addr = getAccountAddress(owner);
        uint256 codeSize = addr.code.length;
        if (codeSize > 0) {
            return Wallet(payable(addr));
        }
        ret = Wallet(
            payable(
                new ERC1967Proxy{salt: bytes32(salts[owner]++)}(
                    address(accountImplementation),
                    abi.encodeCall(Wallet.initialize, (owner))
                )
            )
        );
    }

    function getAccountAddress(address owner) public view virtual returns (address) {
        return
            Create2.computeAddress(
                bytes32(salts[owner]),
                keccak256(
                    abi.encodePacked(
                        type(ERC1967Proxy).creationCode,
                        abi.encode(
                            address(accountImplementation),
                            abi.encodeCall(Wallet.initialize, (owner))
                        )
                    )
                )
            );
    }

    function getAccountAddress(
        address owner,
        uint256 salt
    ) public view virtual returns (address) {
        return
            Create2.computeAddress(
                bytes32(salt),
                keccak256(
                    abi.encodePacked(
                        type(ERC1967Proxy).creationCode,
                        abi.encode(
                            address(accountImplementation),
                            abi.encodeCall(Wallet.initialize, (owner))
                        )
                    )
                )
            );
    }
}
