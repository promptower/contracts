// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// import "hardhat/console.sol";

struct Metadata {
    string name;
    string description;
    string gameType;
    bytes32 prompt;
    bytes32 secret;
    uint128 start;
    uint128 end;
    address winner;
}

interface IGame {
    function awardToken() external view returns (address);

    function metas(uint256) external view returns (Metadata memory);

    // TODO: temp storage
    // enumerable bi-directional mapping
    function counterToTokenId(uint256) external view returns (uint256);

    function tokenIdToCounter(uint256) external view returns (uint256);

    // per-solver status
    function solvedGames(address, uint256) external view returns (uint256);

    function solvedGamesTokenIds(
        address
    ) external view returns (uint256[] memory);

    function solvedCounts(address) external view returns (uint256);

    function solvedAwards(address) external view returns (uint256);

    // total solver status
    function registeredSolver(address) external view returns (bool);

    function solverList(uint256) external view returns (address);

    function solverListLength() external view returns (uint256);

    /* Constructor */

    function initialize(address initialOwner_, address awardToken_) external;

    /* Functions */

    function mint(
        address to,
        Metadata memory metadata,
        uint256 awards
    ) external returns (uint256 tokenId);

    function solved(
        uint256 tokenId,
        bytes32 secretHash,
        address winner,
        bytes memory signature
    ) external;

    function verified(uint256 tokenId, address nftAddress) external;

    /* View Functions */

    function isSolved(uint256 tokenId) external view returns (bool);

    function hasBadge(
        uint256 tokenId,
        address nftAddress
    ) external view returns (bool);

    function totalSolved() external view returns (uint256);

    function totalVerified() external view returns (uint256);

    function totalEnd() external view returns (uint256);

    function totalOngoing() external view returns (uint256);

    function isOngoing(uint256 tokenId) external view returns (bool);

    function isEnded(uint256 tokenId) external view returns (bool);
}
