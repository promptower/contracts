// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Verified is ERC721("Verified Badge", "Verified"), Ownable {
    uint256 public totalSupply;

    constructor() Ownable(msg.sender) {}

    function mint(address to) external onlyOwner {
        _mint(to, totalSupply++);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {} // SBT
}
