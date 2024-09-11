// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// import "hardhat/console.sol";

import {ERC721EnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import {WalletFactory} from "../accounts/WalletFactory.sol";

import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Minimal6551 is ERC721EnumerableUpgradeable, WalletFactory {
    using Strings for uint256;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() WalletFactory() {
        _disableInitializers();
    }

    function initialize(
        string memory name_,
        string memory symbol_
    ) external initializer {
        __ERC721_init_unchained(name_, symbol_);
        __ERC721Enumerable_init_unchained();
        __Minimal6551_init_unchained();
    }

    function __Minimal6551_init() internal onlyInitializing {}

    function __Minimal6551_init_unchained() internal onlyInitializing {
        _setImplementation();
    }

    /* Functions */

    function mint(address to) external virtual returns (uint256 tokenId) {
        tokenId = uint256(uint160(address(createAccount(to))));
        _mint(to, tokenId);
    }

    /* Token URI */

    // function _baseURI() internal pure virtual override returns (string memory) {
    //     return ""; // TODO
    // }

    // // solhint-disable max-line-length
    // function tokenURI(
    //     uint256 tokenId
    // ) public view virtual override returns (string memory) {
    //     _requireOwned(tokenId);

    //     return
    //         string(
    //             abi.encodePacked(
    //                 "data:application/json;base64,",
    //                 Base64.encode(
    //                     bytes(
    //                         string(
    //                             abi.encodePacked(
    //                                 "{",
    //                                 '"name": "', name(), " #", tokenId.toString(), '", ',
    //                                 '"description": "', "Minimal 6551 Implementation.", '", ', // TODO
    //                                 '"image": "', _baseURI(), tokenId.toString(), '"',
    //                                 "}"
    //                             )
    //                         )
    //                     )
    //                 )
    //             )
    //         );
    // }
    // // solhint-enable max-line-length
}
