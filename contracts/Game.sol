// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// import "hardhat/console.sol";

import {Wallet} from "./accounts/Wallet.sol";
import {Minimal6551} from "./minimal6551/Minimal6551.sol";

import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Multicall.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

struct Metadata {
    string gameType;
    bytes32 prompt;
    bytes32 secret;
    uint128 start;
    uint128 end;
    address winner;
}

contract Game is Minimal6551, Multicall, OwnableUpgradeable {
    using Strings for uint256;
    using Strings for address;

    address public awardToken;
    mapping(uint256 tokenId => Metadata) public metas;

    // TODO: temporal storage
    uint256 private _totalSolved;
    uint256 private _totalVerified;
    // uint256 private _totalEnd; // _totalSolved + _totalVerified;
    // uint256 private _totalOngoing; // totalSupply - _totalEnd;
    mapping(address solver => uint256[] tokenIds) public solvedGames;
    mapping(address solver => uint256 count) public solvedCounts;
    mapping(address solver => uint256 totalAwards) public solvedAwards;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() Minimal6551() {
        _disableInitializers();
    }

    function initialize(
        address initialOwner_,
        address awardToken_
    ) external initializer {
        __ERC721_init_unchained("Capture-the-Prompt Game", "CTP");
        __ERC721Enumerable_init_unchained();
        __Minimal6551_init_unchained();
        __Ownable_init_unchained(initialOwner_);
        __Game_init_unchained(awardToken_);
    }

    function __Game_init(address awardToken_) internal onlyInitializing {
        __Game_init_unchained(awardToken_);
    }

    function __Game_init_unchained(
        address awardToken_
    ) internal onlyInitializing {
        awardToken = awardToken_;
    }

    function _msgSender()
        internal
        view
        override(Context, ContextUpgradeable)
        returns (address)
    {
        return msg.sender;
    }

    function _msgData()
        internal
        pure
        override(Context, ContextUpgradeable)
        returns (bytes calldata)
    {
        return msg.data;
    }

    function _contextSuffixLength()
        internal
        pure
        override(Context, ContextUpgradeable)
        returns (uint256)
    {
        return 0;
    }

    /* Functions */

    function mint(address to) external pure override returns (uint256 tokenId) {
        to;
        tokenId;
        revert("Disabled.");
    }

    function mint(
        address to,
        Metadata memory metadata,
        uint256 awards
    ) external returns (uint256 tokenId) {
        /* mint */
        address walletAddress = (address(createAccount(to)));
        tokenId = uint256(uint160(walletAddress));
        _mint(to, tokenId);

        /* metadata */
        metas[tokenId] = Metadata({
            gameType: metadata.gameType,
            prompt: metadata.prompt,
            secret: metadata.secret,
            start: metadata.start,
            end: metadata.end,
            winner: address(0)
        });

        /* awards */
        if (awards != 0) {
            IERC20(awardToken).transferFrom(msg.sender, walletAddress, awards);
        }
    }

    /* Token URI */

    function _baseURI() internal pure override returns (string memory) {
        return ""; // TODO
    }

    // solhint-disable max-line-length
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        _requireOwned(tokenId);

        Metadata memory meta = metas[tokenId];

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            string(
                                abi.encodePacked(
                                    '{',
                                    '"name": "', name(), ' #', tokenId.toString(), '", ',
                                    '"description": "', 'Capture-the-Prompt Game.', '", ',
                                    // '"image": "', _baseURI(), tokenId.toString(), '.png', '", ',
                                    '"image": "', _baseURI(), '", ', // TODO
                                    '"attributes": [',
                                    '{"trait_type": "Type", "value": "', meta.gameType, '"},',
                                    '{"trait_type": "Prompt", "value": "', uint256(meta.prompt).toHexString(32), '"},',
                                    '{"trait_type": "Secret", "value": "', uint256(meta.secret).toHexString(32), '"},',
                                    '{"display_type": "date", "trait_type": "Start date", "value": "', uint256(meta.start).toString(), '"},',
                                    '{"display_type": "date", "trait_type": "End date", "value": "', uint256(meta.end).toString(), '"},',
                                    '{"trait_type": "Winner address", "value": "', meta.winner.toHexString(), '"}',
                                    ']',
                                    '}'
                                )
                            )
                        )
                    )
                )
            );
    }

    // solhint-enable max-line-length

    function solved(uint256 tokenId, address winner) external onlyOwner {
        Metadata storage meta = metas[tokenId];

        require(uint256(meta.start) <= block.timestamp, "Not yet.");
        require(uint256(meta.end) >= block.timestamp, "Outdated.");
        require(meta.winner == address(0), "Already solved.");

        meta.winner = winner;
        _totalSolved += 1;
        solvedGames[winner].push(tokenId);
        solvedCounts[winner] += 1;
        solvedAwards[winner] += IERC20(awardToken).balanceOf(
            address(uint160(tokenId))
        );
        Wallet(payable(address(uint160(tokenId)))).initialize(winner);
    }

    function verified(uint256 tokenId, address nftAddress) external onlyOwner {
        Metadata storage meta = metas[tokenId];

        require(uint256(meta.start) <= block.timestamp, "Not yet.");
        require(uint256(meta.end) >= block.timestamp, "Outdated.");
        require(meta.winner == address(0), "Already solved.");
        require(
            IERC721(nftAddress).balanceOf(address(uint160(tokenId))) != 0,
            "Have no badges."
        );

        meta.winner = address(type(uint160).max);
        _totalVerified += 1;
    }

    /* View Functions */

    function isSolved(uint256 tokenId) public view returns (bool) {
        return metas[tokenId].winner != address(0);
    }

    function hasBadge(
        uint256 tokenId,
        address nftAddress
    ) public view returns (bool) {
        return IERC721(nftAddress).balanceOf(address(uint160(tokenId))) != 0;
    }

    function totalSolved() public view returns (uint256) {
        return _totalSolved;
    }

    function totalVerified() public view returns (uint256) {
        return _totalVerified;
    }

    function totalEnd() public view returns (uint256) {
        return _totalSolved + _totalVerified;
    }

    function totalOngoing() public view returns (uint256) {
        return totalSupply() - totalEnd();
    }

    function isOngoing(uint256 tokenId) public view returns (bool) {
        Metadata storage meta = metas[tokenId];
        return
            (uint256(meta.start) <= block.timestamp) &&
            (uint256(meta.end) >= block.timestamp);
    }

    function isEnded(uint256 tokenId) public view returns (bool) {
        Metadata storage meta = metas[tokenId];
        return (uint256(meta.end) < block.timestamp);
    }
}
