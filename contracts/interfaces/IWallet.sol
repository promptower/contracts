// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

interface IWallet {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4);

    /* Factory functions */

    function initialize(address newOwner_) external;

    /* execute functions */

    function execute(
        address dest,
        uint256 value,
        bytes calldata func
    ) external payable returns (bytes memory result);

    function executeBatch(
        address[] calldata dest,
        uint256[] calldata value,
        bytes[] calldata func
    ) external payable returns (bytes[] memory results);
}
